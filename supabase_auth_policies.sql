-- AUSC Alumni: require an account to add profiles
-- Run in Supabase SQL Editor after supabase_setup.sql.
--
-- Also in the dashboard: Authentication > Sign In / Providers > Email
--   * keep "Enable Email provider" ON
--   * turn "Confirm email" OFF (the app signs up with phone numbers mapped to
--     placeholder emails, so a confirmation email could never be delivered)

-- Remember who created each profile. Existing rows stay unowned (NULL).
ALTER TABLE alumni
  ADD COLUMN IF NOT EXISTS user_id UUID DEFAULT auth.uid()
  REFERENCES auth.users(id) ON DELETE SET NULL;

-- Replace the development "anyone can do anything" policy.
DROP POLICY IF EXISTS "Allow all access" ON alumni;
DROP POLICY IF EXISTS "Anyone can read alumni" ON alumni;
DROP POLICY IF EXISTS "Signed-in users can add alumni" ON alumni;
DROP POLICY IF EXISTS "Owners can update their alumni" ON alumni;
DROP POLICY IF EXISTS "Owners can delete their alumni" ON alumni;

CREATE POLICY "Anyone can read alumni" ON alumni
  FOR SELECT USING (true);

CREATE POLICY "Signed-in users can add alumni" ON alumni
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owners can update their alumni" ON alumni
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Owners can delete their alumni" ON alumni
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());
