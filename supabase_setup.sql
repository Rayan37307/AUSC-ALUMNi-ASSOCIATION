-- Supabase Setup Script for AUSC Alumni App
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new

-- Create alumni table
CREATE TABLE IF NOT EXISTS alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  current_address TEXT DEFAULT '',
  permanent_address TEXT DEFAULT '',
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
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'alumni' AND column_name = 'district') THEN
    UPDATE alumni
    SET permanent_address = concat_ws(', ',
      NULLIF(village, ''), NULLIF(post_office, ''),
      NULLIF(upazila, ''), NULLIF(district, ''))
    WHERE coalesce(permanent_address, '') = '';
    ALTER TABLE alumni
      DROP COLUMN village, DROP COLUMN post_office,
      DROP COLUMN upazila, DROP COLUMN district;
  END IF;
END $$;

-- Achievements are no longer collected. Uncomment to delete the old column
-- (and any achievements already saved) from an existing table:
-- ALTER TABLE alumni DROP COLUMN IF EXISTS achievements;

-- Enable Row Level Security
ALTER TABLE alumni ENABLE ROW LEVEL SECURITY;

-- Allow all access (for development - restrict in production!)
DROP POLICY IF EXISTS "Allow all access" ON alumni;
CREATE POLICY "Allow all access" ON alumni
  FOR ALL USING (true)
  WITH CHECK (true);

-- Create index for sorting
CREATE INDEX IF NOT EXISTS idx_alumni_created_at ON alumni(created_at DESC);

-- Insert sample data (optional)
INSERT INTO alumni (name, phone, batch_year, position, currently_doing, current_address, permanent_address)
VALUES 
  ('Md. Rahim Ahmed', '01712345678', '1990', 'Software Engineer', 'Working at Google', 'Mirpur, Dhaka', 'Mirpur, Dhaka'),
  ('Fatema Begum', '01812345679', '1995', 'Doctor', 'Working at DMCH', 'Mohammadpur, Dhaka', 'Mohammadpur, Dhaka'),
  ('Karim Hossain', '01912345680', '2000', 'Student', 'Studying at BUET', 'Dhanmondi, Dhaka', 'Dhanmondi, Dhaka');
