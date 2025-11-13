-- Create storage bucket for outfit images
-- This bucket will store generated outfit images from Segmind API

-- Create the bucket (if it doesn't exist)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'outfits',
  'outfits',
  true, -- Make bucket public so images can be accessed via URL
  52428800, -- 50MB file size limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'] -- Allowed image types
)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies if they exist (to allow re-running this migration)
DROP POLICY IF EXISTS "Authenticated users can upload outfit images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view outfit images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own outfit images" ON storage.objects;

-- Create storage policy: Allow authenticated users to upload files
-- Note: Edge Functions use service role, so they can upload without this policy
-- But we create it for direct client uploads if needed
CREATE POLICY "Authenticated users can upload outfit images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'outfits' AND
  (storage.foldername(name))[1] = auth.uid()::text -- Users can only upload to their own folder
);

-- Create storage policy: Allow public read access to outfit images
CREATE POLICY "Public can view outfit images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'outfits');

-- Create storage policy: Allow users to delete their own outfit images
CREATE POLICY "Users can delete their own outfit images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'outfits' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

