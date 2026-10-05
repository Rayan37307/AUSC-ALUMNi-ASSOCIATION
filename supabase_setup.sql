-- Supabase Setup Script for AUSC Alumni App
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new

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

-- Create photos table for the gallery
CREATE TABLE IF NOT EXISTS photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security on photos
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read photos (gallery view)
CREATE POLICY "Anyone can read photos" ON photos
  FOR SELECT USING (true);

-- Policy: Only the admin account can upload photos
-- Replace 'admin-user-id-here' with the actual admin user ID
CREATE POLICY "Admin can upload photos" ON photos
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = '00000000-0000-0000-0000-000000000000');  -- TODO: Replace with actual admin UUID

-- Policy: Users can update their own photos
CREATE POLICY "Users can update their own photos" ON photos
  FOR UPDATE TO authenticated
  USING (uploaded_by = auth.uid())
  WITH CHECK (uploaded_by = auth.uid());

-- Policy: Users can delete their own photos
CREATE POLICY "Users can delete their own photos" ON photos
  FOR DELETE TO authenticated
  USING (uploaded_by = auth.uid());

-- Create index for sorting
CREATE INDEX IF NOT EXISTS idx_photos_created_at ON photos(created_at DESC);

-- Insert sample data (optional)
INSERT INTO alumni (name, phone, batch_year, position, currently_doing, current_address, permanent_address, blood_group)
VALUES 
  ('Md. Rahim Ahmed', '01712345678', '1990', 'Software Engineer', 'Working at Google', 'Mirpur, Dhaka', 'Mirpur, Dhaka', 'A+'),
  ('Fatema Begum', '01812345679', '1995', 'Doctor', 'Working at DMCH', 'Mohammadpur, Dhaka', 'Mohammadpur, Dhaka', 'B+'),
  ('Karim Hossain', '01912345680', '2000', 'Student', 'Studying at BUET', 'Dhanmondi, Dhaka', 'Dhanmondi, Dhaka', 'O+');