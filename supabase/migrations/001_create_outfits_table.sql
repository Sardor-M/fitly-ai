-- Create outfits table to store generated outfit history
CREATE TABLE IF NOT EXISTS outfits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  style TEXT NOT NULL,
  selfie_url TEXT,
  palette_name TEXT,
  palette_colors TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS outfits_user_id_idx ON outfits(user_id);
CREATE INDEX IF NOT EXISTS outfits_created_at_idx ON outfits(created_at DESC);
CREATE INDEX IF NOT EXISTS outfits_style_idx ON outfits(style);

-- Enable Row Level Security
ALTER TABLE outfits ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only see their own outfits
CREATE POLICY "Users can view their own outfits"
  ON outfits FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy: Users can insert their own outfits
CREATE POLICY "Users can insert their own outfits"
  ON outfits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can update their own outfits
CREATE POLICY "Users can update their own outfits"
  ON outfits FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policy: Users can delete their own outfits
CREATE POLICY "Users can delete their own outfits"
  ON outfits FOR DELETE
  USING (auth.uid() = user_id);

