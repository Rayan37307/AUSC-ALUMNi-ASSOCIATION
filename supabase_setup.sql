# Supabase Setup Script for AUSC Alumni App
# Run this in Supabase SQL Editor: https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new

-- Create alumni table
CREATE TABLE IF NOT EXISTS alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  village TEXT DEFAULT '',
  post_office TEXT DEFAULT '',
  upazila TEXT DEFAULT '',
  district TEXT DEFAULT '',
  currently_doing TEXT DEFAULT '',
  achievements TEXT DEFAULT '',
  batch_year TEXT NOT NULL,
  position TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

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
INSERT INTO alumni (name, phone, batch_year, position, currently_doing, village, district)
VALUES 
  ('Md. Rahim Ahmed', '01712345678', '1990', 'Software Engineer', 'Working at Google', 'Mirpur', 'Dhaka'),
  ('Fatema Begum', '01812345679', '1995', 'Doctor', 'Working at DMCH', 'Mohammadpur', 'Dhaka'),
  ('Karim Hossain', '01912345680', '2000', 'Student', 'Studying at BUET', 'Dhanmondi', 'Dhaka');
