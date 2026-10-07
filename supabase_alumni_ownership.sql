-- AUSC Alumni: restrict alumni writes to the member who owns the entry.
--
-- Run this in the Supabase SQL Editor AFTER supabase_setup.sql, then replace the
-- old blanket policy from supabase_setup.sql.
--
-- Every block is safe to re-run.
--
-- What this changes:
--   - Adds alumni.owner_id, set automatically to the signed-in member on insert
--   - Anyone may still READ the directory (it is a public directory)
--   - INSERT, UPDATE and DELETE are limited to the row's owner, or to an admin
--
-- is_admin() is defined in supabase_setup.sql as SECURITY DEFINER, so it can be
-- called from these policies without recursing back into the admins policy.

-- ============================================================================
-- 1. OWNER COLUMN
-- ============================================================================
-- DEFAULT auth.uid() stamps the member automatically, so the client never has
-- to send it and cannot forge it.
ALTER TABLE alumni ADD COLUMN IF NOT EXISTS owner_id UUID DEFAULT auth.uid();

-- Backfill: rows created before this migration have no owner. Claim them for the
-- earliest admin so the directory is not left unmanageable, or set them to NULL
-- to leave them read-only for everyone except admins. Both are safe to re-run.
DO $$
DECLARE
  first_admin UUID;
BEGIN
  SELECT user_id INTO first_admin FROM public.admins ORDER BY created_at LIMIT 1;

  IF first_admin IS NOT NULL THEN
    UPDATE alumni SET owner_id = first_admin WHERE owner_id IS NULL;
  ELSE
    RAISE NOTICE 'No admins found; existing alumni rows left unowned and admin-only.';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_alumni_owner_id ON alumni(owner_id);

-- ============================================================================
-- 2. READ: open to everyone, same as before
-- ============================================================================
DROP POLICY IF EXISTS "Allow all access" ON alumni;
DROP POLICY IF EXISTS "Anyone can read alumni" ON alumni;

CREATE POLICY "Anyone can read alumni" ON alumni
  FOR SELECT USING (true);

-- ============================================================================
-- 3. INSERT: you may only create rows you own
-- ============================================================================
-- owner_id is filled from auth.uid() by the column default. The check compares
-- the resulting row against the caller, so a client cannot submit someone
-- else's id.
DROP POLICY IF EXISTS "Authenticated can add alumni" ON alumni;
DROP POLICY IF EXISTS "Allow all access" ON alumni;

CREATE POLICY "Authenticated can add alumni" ON alumni
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- ============================================================================
-- 4. UPDATE / DELETE: your own row, or any row if you are an admin
-- ============================================================================
DROP POLICY IF EXISTS "Members can update own alumni" ON alumni;

CREATE POLICY "Members can update own alumni" ON alumni
  FOR UPDATE TO authenticated
  USING (owner_id = auth.uid() OR public.is_admin())
  WITH CHECK (owner_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "Members can delete own alumni" ON alumni;

CREATE POLICY "Members can delete own alumni" ON alumni
  FOR DELETE TO authenticated
  USING (owner_id = auth.uid() OR public.is_admin());

-- ============================================================================
-- 5. GRANTS
-- ============================================================================
-- Grants and RLS policies are separate layers: the grant decides whether the
-- role may issue the statement at all, the policy then decides which rows pass.
-- Both need to allow it. anon keeps SELECT only so signed-out visitors can still
-- browse the directory.
REVOKE ALL ON alumni FROM anon, authenticated;
GRANT SELECT ON alumni TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON alumni TO authenticated;

-- ============================================================================
-- 6. VERIFY
-- ============================================================================
SELECT policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'alumni'
ORDER BY cmd, policyname;

-- Count of rows with no owner. Anything above 0 is not editable by its creator.
SELECT count(*) AS unowned_rows FROM alumni WHERE owner_id IS NULL;

-- ============================================================================
-- 7. EDITING BY PHONE NUMBER
-- ============================================================================
-- Transfer an entry to the member who actually owns it. Replace the number with
-- theirs; it is stored canonically as 8801XXXXXXXXX.
--
-- UPDATE alumni a
-- SET owner_id = u.id
-- FROM auth.users u
-- WHERE u.raw_user_meta_data->>'phone' = '8801712345678'
--   AND a.name = 'Md. Rahim Ahmed';

-- Take an entry back from a member who has left:
-- UPDATE alumni SET owner_id = NULL WHERE id = '<entry-uuid>';