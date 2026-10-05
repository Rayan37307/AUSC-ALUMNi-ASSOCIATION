-- Supabase Setup Script for AUSC Alumni App
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new
--
-- Safe to re-run: every statement is IF NOT EXISTS / DROP IF EXISTS.
-- Order: setup first, then grant an admin, then supabase_auth_policies.sql.

-- Create alumni table
CREATE TABLE IF NOT EXISTS alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  current_address TEXT DEFAULT '',
  permanent_address TEXT DEFAULT '',
  blood_group TEXT DEFAULT '',  -- NEW: Blood group (A+, A-, B+, B-, AB+, AB-, O+, O-)
  currently_doing TEXT DEFAULT '',
  batch_year TEXT NOT NULL,
  position TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Migration for tables created with the old village/post_office/upazila/district
-- columns: add the two address columns and fold the old parts into permanent_address.
ALTER TABLE alumni ADD COLUMN IF NOT EXISTS current_address TEXT DEFAULT '';
ALTER TABLE alumni ADD COLUMN IF NOT EXISTS permanent_address TEXT DEFAULT '';
ALTER TABLE alumni ADD COLUMN IF NOT EXISTS blood_group TEXT DEFAULT '';  -- NEW: Blood group column
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'alumni' AND column_name = 'district') THEN
    UPDATE alumni
    SET permanent_address = concat_ws(', ', NULLIF(village, ''), NULLIF(post_office, ''),
      NULLIF(upazila, ''), NULLIF(district, ''))
    WHERE coalesce(permanent_address, '') = '';
    ALTER TABLE alumni
      DROP COLUMN village, DROP COLUMN post_office, DROP COLUMN upazila, DROP COLUMN district;
  END IF;
END $$;

-- Achievements are no longer collected. Uncomment to delete the old column
-- (and any achievements already saved) from an existing table:
-- ALTER TABLE alumni DROP COLUMN IF EXISTS achievements;

-- Admins table. Listing a user id here is what grants photo-upload rights.
CREATE TABLE IF NOT EXISTS admins (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- The app queries this table to decide whether to show upload controls, so a
-- signed-in user may only ever read their own row.
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can read own record" ON admins;
CREATE POLICY "Admins can read own record" ON admins
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

-- True when the caller is listed above. SECURITY DEFINER lets RLS policies on
-- other tables call it without recursing back into the admins policy.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM public.admins WHERE user_id = auth.uid());
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- Create photos table for the gallery
CREATE TABLE IF NOT EXISTS photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Storage bucket that holds the image files. Public so the gallery can render
-- thumbnails without signed URLs; writes are gated by RLS below.
INSERT INTO storage.buckets (id, name, public)
VALUES ('gallery', 'gallery', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Enable Row Level Security on photos
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read photos (gallery view)
DROP POLICY IF EXISTS "Anyone can read photos" ON photos;
CREATE POLICY "Anyone can read photos" ON photos
  FOR SELECT USING (true);

-- Policy: Only admins can upload photos
DROP POLICY IF EXISTS "Admin can upload photos" ON photos;
CREATE POLICY "Admin can upload photos" ON photos
  FOR INSERT TO authenticated
  WITH CHECK (public.is_admin());

-- Policy: Only admins can edit photos
DROP POLICY IF EXISTS "Users can update their own photos" ON photos;
CREATE POLICY "Users can update their own photos" ON photos
  FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Policy: Only admins can delete photos
DROP POLICY IF EXISTS "Users can delete their own photos" ON photos;
CREATE POLICY "Users can delete their own photos" ON photos
  FOR DELETE TO authenticated
  USING (public.is_admin());

-- Storage RLS: anyone can read, only admins can write. The folder name must
-- match the uploader's uid so one admin cannot overwrite another's files.
DROP POLICY IF EXISTS "Anyone can read gallery files" ON storage.objects;
CREATE POLICY "Anyone can read gallery files" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery');

DROP POLICY IF EXISTS "Admins can upload gallery files" ON storage.objects;
CREATE POLICY "Admins can upload gallery files" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'gallery'
    AND public.is_admin()
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Admins can update gallery files" ON storage.objects;
CREATE POLICY "Admins can update gallery files" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'gallery' AND public.is_admin())
  WITH CHECK (bucket_id = 'gallery' AND public.is_admin());

DROP POLICY IF EXISTS "Admins can delete gallery files" ON storage.objects;
CREATE POLICY "Admins can delete gallery files" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'gallery' AND public.is_admin());

-- Create index for sorting
CREATE INDEX IF NOT EXISTS idx_photos_created_at ON photos(created_at DESC);

-- ============================================================================
-- GRANT ADMIN RIGHTS
-- ============================================================================
-- An admin is just a row in the admins table above. See supabase_admins.sql for
-- the full set of grant/revoke queries; the short version is:

--   INSERT INTO admins (user_id, email)
--   SELECT id, email FROM auth.users
--   WHERE raw_user_meta_data->>'phone' = '8801712345678'
--   ON CONFLICT (user_id) DO UPDATE SET email = EXCLUDED.email;

-- The person must already have signed up through the app. Verify with:
--   SELECT * FROM admins;

-- Sample data. The WHERE guard keeps re-running the script from piling up
-- duplicates on an existing table.
INSERT INTO alumni (name, phone, batch_year, position, currently_doing, current_address, permanent_address, blood_group)
SELECT * FROM (VALUES
  ('Md. Rahim Ahmed', '01712345678', '1990', 'Software Engineer', 'Working at Google', 'Mirpur, Dhaka', 'Mirpur, Dhaka', 'A+'),
  ('Fatema Begum', '01812345679', '1995', 'Doctor', 'Working at DMCH', 'Mohammadpur, Dhaka', 'Mohammadpur, Dhaka', 'B+'),
  ('Karim Hossain', '01912345680', '2000', 'Student', 'Studying at BUET', 'Dhanmondi, Dhaka', 'Dhanmondi, Dhaka', 'O+')
) AS seed(name, phone, batch_year, position, currently_doing, current_address, permanent_address, blood_group)
WHERE NOT EXISTS (SELECT 1 FROM alumni WHERE phone = '01712345678');