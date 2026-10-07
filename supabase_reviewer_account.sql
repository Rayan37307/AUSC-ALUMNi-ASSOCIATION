-- AUSC Alumni: set up a Google Play reviewer account.
--
-- Play requires working sign-in details for any app where content is gated
-- behind an account. This script handles the database side.
--
-- IMPORTANT: read section 1 before running anything.
--
-- Every block is safe to re-run.

-- ============================================================================
-- 1. PREFER CREATING THE ACCOUNT IN THE APP
-- ============================================================================
-- Do this first, before running the SQL below:
--
--   1. In Supabase: Authentication -> Sign In / Providers -> Email
--   2. Turn OFF "Confirm email"
--   3. In the app: Create an account -> enter the phone number and password
--      from section 5 -> Create account
--   4. Sign in with it to prove it works
--
-- This is the supported route. The app calls Supabase Auth's signUp, which
-- handles password hashing and internal bookkeeping correctly.
--
-- Creating the auth user by inserting into auth.users directly does work, but
-- it is not a documented API and Supabase can change those internals without
-- notice. Use section 2 below only if signing up through the app is impossible
-- (for example the app cannot reach Supabase from your network).
--
-- SECURITY: turn "Confirm email" back ON after creating the account if you
-- like. Once the account exists and is confirmed, sign-in works regardless.

-- ============================================================================
-- 2. CREATE THE REVIEWER ACCOUNT DIRECTLY (fallback only)
-- ============================================================================
-- The phone must be canonical: 8801 then 9 digits starting 3-9. The app maps it
-- to the placeholder address <phone>@phone.ausc-alumni.app.
--
-- SET THESE TWO VALUES FIRST.
--   reviewer_password : 12+ characters, memorable enough to type
--   reviewer_phone    : the canonical number, digits only
--
-- crypt() is Supabase's bcrypt helper, so the password is stored hashed.

-- BEGIN;
-- -- Replace both values before running.
-- SELECT set_config(
--   'reviewer.phone',    '8801712345678',           true),
--   set_config(
--   'reviewer.password', 'ChangeMe-Play-Review-2026', true);

-- INSERT INTO auth.users (
--   instance_id,
--   id,
--   aud,
--   role,
--   email,
--   encrypted_password,
--   email_confirmed_at,
--   created_at,
--   updated_at,
--   raw_app_meta_data,
--   raw_user_meta_data
-- )
-- SELECT
--   '00000000-0000-0000-0000-000000000000',
--   gen_random_uuid(),
--   'authenticated',
--   'authenticated',
--   current_setting('reviewer.phone') || '@phone.ausc-alumni.app',
--   crypt(current_setting('reviewer.password'), gen_salt('bf')),
--   now(),
--   now(),
--   now(),
--   '{"provider":"email","providers":["email"]}'::jsonb,
--   jsonb_build_object(
--     'full_name', 'Play Reviewer',
--     'phone',     current_setting('reviewer.phone')
--   )
-- ON CONFLICT (email) DO NOTHING;
-- COMMIT;

-- Verify the account exists and its metadata is right:
SELECT id,
       email,
       email_confirmed_at IS NOT NULL AS confirmed,
       raw_user_meta_data
FROM auth.users
WHERE email = '8801712345678@phone.ausc-alumni.app';

-- ============================================================================
-- 3. MAKE SURE IT IS NOT AN ADMIN
-- ============================================================================
-- The reviewer account should be an ordinary member. Admin accounts can upload
-- and delete gallery photos, and you do not want a Play reviewer deleting them.
--
-- If the query below returns a row, run the DELETE underneath it.

SELECT a.user_id, u.raw_user_meta_data->>'phone' AS phone
FROM admins a
JOIN auth.users u ON u.id = a.user_id
WHERE u.email = '8801712345678@phone.ausc-alumni.app';

-- DELETE FROM admins
-- WHERE user_id IN (
--   SELECT id FROM auth.users
--   WHERE email = '8801712345678@phone.ausc-alumni.app'
-- );

-- ============================================================================
-- 4. MAKE SURE IT OWNS AN ALUMNI ENTRY
-- ============================================================================
-- So the reviewer can see the edit and delete controls on at least one entry,
-- which is the part of the app most likely to need review.
--
-- Reuses the seed data from supabase_setup.sql. Safe to re-run.

INSERT INTO alumni (name, phone, batch_year, position, currently_doing,
                    current_address, permanent_address)
SELECT 'Md. Rahim Ahmed', '01712345678', '1990', 'Software Engineer',
       'Working at Google', 'Mirpur, Dhaka', 'Mirpur, Dhaka'
WHERE NOT EXISTS (
  SELECT 1 FROM alumni WHERE name = 'Md. Rahim Ahmed'
);

UPDATE alumni a
SET owner_id = u.id
FROM auth.users u
WHERE u.email = '8801712345678@phone.ausc-alumni.app'
  AND a.name = 'Md. Rahim Ahmed'
  AND (a.owner_id IS NULL OR a.owner_id <> u.id);

-- ============================================================================
-- 5. CONFIRMATION OUTPUT
-- ============================================================================
-- Run this last. Everything should read TRUE / 1 row.
--
--   Account exists and confirmed : true
--   Not an admin                 : true
--   Owns an alumni entry         : 1

SELECT
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE email = '8801712345678@phone.ausc-alumni.app'
      AND email_confirmed_at IS NOT NULL
  ) AS account_exists_and_confirmed,
  NOT EXISTS (
    SELECT 1 FROM admins a
    JOIN auth.users u ON u.id = a.user_id
    WHERE u.email = '8801712345678@phone.ausc-alumni.app'
  ) AS not_an_admin,
  (
    SELECT count(*) FROM alumni a
    JOIN auth.users u
      ON u.email = '8801712345678@phone.ausc-alumni.app'
    WHERE a.owner_id = u.id
  ) AS alumni_owned;