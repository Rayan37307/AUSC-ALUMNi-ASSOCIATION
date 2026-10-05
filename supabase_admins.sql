-- AUSC Alumni: manage admin accounts
-- Run in the Supabase SQL Editor after supabase_setup.sql.
--   https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new
--
-- An "admin" is simply a row in the public.admins table. Nothing else needs
-- changing: the app reads that table on sign-in to decide whether to show
-- upload controls, and the RLS policies call public.is_admin() so the server
-- rejects writes from everyone else.
--
-- Phone numbers are stored canonically as 8801XXXXXXXXX (13 digits, no + or
-- dashes). The app normalises whatever you type on the signup form into that
-- form, so 01712345678, +8801712345678 and 8801712345678 all match the same
-- account.
--
-- Every block below is safe to run more than once.

-- ============================================================================
-- 1. WHO IS AN ADMIN
-- ============================================================================
SELECT a.user_id,
       a.email,
       u.raw_user_meta_data->>'phone' AS phone,
       u.raw_user_meta_data->>'full_name' AS name,
       a.created_at
FROM admins a
LEFT JOIN auth.users u ON u.id = a.user_id
ORDER BY a.created_at;


-- ============================================================================
-- 2. GRANT ADMIN - BY PHONE NUMBER (easiest)
-- ============================================================================
-- Replace the number below with the account's mobile number, then run.
-- The phone must be exactly 8801 followed by a 9-digit number starting 3-9.
-- If nothing is inserted, the account does not exist yet: have the person sign
-- up through the app first.

INSERT INTO admins (user_id, email)
SELECT id, email
FROM auth.users
WHERE raw_user_meta_data->>'phone' = '8801712345678'
ON CONFLICT (user_id) DO UPDATE SET email = EXCLUDED.email;

-- Confirm it worked:
SELECT u.raw_user_meta_data->>'phone' AS phone,
       EXISTS (SELECT 1 FROM admins a WHERE a.user_id = u.id) AS is_admin
FROM auth.users u
WHERE u.raw_user_meta_data->>'phone' = '8801712345678';


-- ============================================================================
-- 3. GRANT ADMIN - BY EMAIL (if you know the placeholder address)
-- ============================================================================
-- Placeholder emails are <phone>@phone.ausc-alumni.app because Supabase's SMS
-- provider needs a paid plan. Never change the domain in AuthProvider once
-- people have signed up, or existing accounts are orphaned.
--
-- INSERT INTO admins (user_id, email)
-- SELECT id, email FROM auth.users WHERE email = '8801712345678@phone.ausc-alumni.app'
-- ON CONFLICT (user_id) DO UPDATE SET email = EXCLUDED.email;


-- ============================================================================
-- 4. GRANT ADMIN TO EVERYONE (useful for local testing only)
-- ============================================================================
-- WARNING: this makes every signed-in account an admin. Do NOT run this against
-- the live project - anyone who signs up could upload and delete photos.
--
-- INSERT INTO admins (user_id, email)
-- SELECT id, email FROM auth.users
-- ON CONFLICT (user_id) DO NOTHING;


-- ============================================================================
-- 5. REVOKE ADMIN
-- ============================================================================
-- By phone number:
-- DELETE FROM admins
-- WHERE user_id IN (
--   SELECT id FROM auth.users
--   WHERE raw_user_meta_data->>'phone' = '8801712345678'
-- );

-- By email:
-- DELETE FROM admins
-- WHERE user_id IN (SELECT id FROM auth.users WHERE email = 'you@example.com');

-- Everybody at once:
-- TRUNCATE admins;


-- ============================================================================
-- 6. WHY THE CLIENT CANNOT CHEAT
-- ============================================================================
-- The app queries `admins` to decide whether to render the upload button, but
-- that query is filtered by row-level security:
--
--   CREATE POLICY "Admins can read own record" ON admins
--     FOR SELECT TO authenticated USING (user_id = auth.uid());
--
-- So a client asking "am I an admin?" can only ever see its own row. Hiding
-- the button in the UI is only cosmetic anyway - the real enforcement is in the
-- photos and storage.objects policies, which both call public.is_admin() and
-- are evaluated server-side. Tampering with the app cannot bypass them.
--
-- public.is_admin() is SECURITY DEFINER so it can be called from those policies
-- without the admins policy recursing into itself.