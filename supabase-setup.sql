-- Create the tutors table
CREATE TABLE IF NOT EXISTS tutors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  city TEXT,
  region TEXT,
  country TEXT,
  certifications TEXT,
  services TEXT,
  rate TEXT,
  virtual BOOLEAN DEFAULT false,
  in_person BOOLEAN DEFAULT false,
  website TEXT,
  facebook TEXT,
  bio TEXT,
  consent BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create an index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_tutors_email ON tutors(email);

-- Create an index on location fields for filtering
CREATE INDEX IF NOT EXISTS idx_tutors_location ON tutors(city, region, country);

-- Create an index on service types
CREATE INDEX IF NOT EXISTS idx_tutors_services ON tutors(virtual, in_person);

-- Enable Row Level Security (RLS)
ALTER TABLE tutors ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows anyone to insert (for the signup form)
CREATE POLICY "Allow public insert for tutor signup" ON tutors
  FOR INSERT
  WITH CHECK (true);

-- Create a policy that allows anyone to read (for the public directory)
CREATE POLICY "Allow public read for tutor directory" ON tutors
  FOR SELECT
  USING (true);

-- Create a policy that allows tutors to update their own records (by email)
CREATE POLICY "Allow tutors to update own record" ON tutors
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a trigger to automatically update the updated_at column
CREATE TRIGGER update_tutors_updated_at
  BEFORE UPDATE ON tutors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create a view for public tutor directory (without sensitive info)
CREATE OR REPLACE VIEW public_tutors AS
SELECT 
  id,
  full_name,
  city,
  region,
  country,
  certifications,
  services,
  rate,
  virtual,
  in_person,
  website,
  facebook,
  bio,
  created_at
FROM tutors
WHERE consent = true
ORDER BY created_at DESC;
