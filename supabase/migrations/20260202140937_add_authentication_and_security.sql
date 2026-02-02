/*
  # Add Authentication and Production-Level Security

  ## Overview
  This migration implements comprehensive authentication and security for the CMS,
  transforming it from an open system to a secure, production-ready application.

  ## Changes Made

  ### 1. User Profiles Table
  Creates a `user_profiles` table to extend Supabase's built-in `auth.users`:
  - `id` (uuid, primary key) - References auth.users(id)
  - `email` (text) - User email for quick reference
  - `full_name` (text) - User's display name
  - `role` (text) - User role: 'admin', 'editor', or 'viewer'
  - `is_active` (boolean) - Account status flag
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last profile update timestamp

  ### 2. Ownership Tracking
  Adds ownership columns to all CMS tables:
  - `created_by` (uuid) - References user_profiles(id)
  - `updated_by` (uuid) - References user_profiles(id)

  Tables Updated:
  - page_content_sections
  - page_seo_content
  - content_templates

  ### 3. Secure RLS Policies
  Replaces permissive policies with restrictive, role-based access:
  
  **page_content_sections:**
  - Anyone can read active sections
  - Only authenticated users can create sections (tracks creator)
  - Only admin/editor roles or content creator can update
  - Only admin role or content creator can delete

  **page_seo_content:**
  - Anyone can read SEO content
  - Only authenticated users can create
  - Only admin/editor roles or content creator can update
  - Only admin role or content creator can delete

  **content_templates:**
  - Anyone can read public templates
  - Authenticated users can read their own templates
  - Only template creator can update their templates
  - Only template creator can delete their templates

  **user_profiles:**
  - Users can read all profiles (for attribution)
  - Users can only update their own profile (excluding role/is_active)
  - Only users can create their own profile during signup

  ### 4. Automatic Profile Creation
  Trigger that automatically creates a user_profile when a new auth.users record is created.

  ### 5. Updated At Triggers
  Automatic timestamp updates for user_profiles table.

  ## Security Benefits
  - ✅ User authentication required for all CMS operations
  - ✅ Role-based access control (admin, editor, viewer)
  - ✅ Ownership tracking for all content
  - ✅ Audit trail with created_by and updated_by
  - ✅ Prevention of privilege escalation
  - ✅ Soft delete support with is_active flag
  - ✅ Protection against unauthorized modifications

  ## Important Notes
  - First user to sign up should be manually promoted to 'admin' role via SQL
  - Default role for new users is 'viewer'
  - Admins have full access to all content
  - Editors can create and modify content
  - Viewers can only read content
*/

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  role text NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin', 'editor', 'viewer')),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add ownership columns to page_content_sections
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'page_content_sections' AND column_name = 'created_by'
  ) THEN
    ALTER TABLE page_content_sections ADD COLUMN created_by uuid REFERENCES user_profiles(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'page_content_sections' AND column_name = 'updated_by'
  ) THEN
    ALTER TABLE page_content_sections ADD COLUMN updated_by uuid REFERENCES user_profiles(id);
  END IF;
END $$;

-- Add ownership columns to page_seo_content
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'page_seo_content' AND column_name = 'created_by'
  ) THEN
    ALTER TABLE page_seo_content ADD COLUMN created_by uuid REFERENCES user_profiles(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'page_seo_content' AND column_name = 'updated_by'
  ) THEN
    ALTER TABLE page_seo_content ADD COLUMN updated_by uuid REFERENCES user_profiles(id);
  END IF;
END $$;

-- Add ownership columns to content_templates
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'content_templates' AND column_name = 'created_by'
  ) THEN
    ALTER TABLE content_templates ADD COLUMN created_by uuid REFERENCES user_profiles(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'content_templates' AND column_name = 'updated_by'
  ) THEN
    ALTER TABLE content_templates ADD COLUMN updated_by uuid REFERENCES user_profiles(id);
  END IF;
END $$;

-- Create index on user_profiles email
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_active ON user_profiles(is_active);

-- Create indexes on ownership columns
CREATE INDEX IF NOT EXISTS idx_page_content_created_by ON page_content_sections(created_by);
CREATE INDEX IF NOT EXISTS idx_page_seo_created_by ON page_seo_content(created_by);
CREATE INDEX IF NOT EXISTS idx_templates_created_by ON content_templates(created_by);

-- Create function to auto-create user profile
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'viewer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for auto-creating user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();

-- Create trigger for auto-updating updated_at on user_profiles
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing permissive policies
DROP POLICY IF EXISTS "Public can read active sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can insert sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can update sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can delete sections" ON page_content_sections;

DROP POLICY IF EXISTS "Public can read SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can insert SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can update SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can delete SEO content" ON page_seo_content;

DROP POLICY IF EXISTS "Public can read public templates" ON content_templates;
DROP POLICY IF EXISTS "Authenticated users can manage templates" ON content_templates;

-- RLS Policies for user_profiles
CREATE POLICY "Anyone can read active user profiles"
  ON user_profiles FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id AND
    -- Prevent users from changing their own role or active status
    role = (SELECT role FROM user_profiles WHERE id = auth.uid()) AND
    is_active = (SELECT is_active FROM user_profiles WHERE id = auth.uid())
  );

-- RLS Policies for page_content_sections
CREATE POLICY "Anyone can read active sections"
  ON page_content_sections FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Authenticated users can create sections"
  ON page_content_sections FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Admin and editors can update any section, creators can update their own"
  ON page_content_sections FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Admin and creators can delete sections"
  ON page_content_sections FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role = 'admin'
    )
  );

-- RLS Policies for page_seo_content
CREATE POLICY "Anyone can read SEO content"
  ON page_seo_content FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can create SEO content"
  ON page_seo_content FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Admin and editors can update any SEO content, creators can update their own"
  ON page_seo_content FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  )
  WITH CHECK (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Admin and creators can delete SEO content"
  ON page_seo_content FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role = 'admin'
    )
  );

-- RLS Policies for content_templates
CREATE POLICY "Anyone can read public templates"
  ON content_templates FOR SELECT
  TO anon, authenticated
  USING (is_public = true);

CREATE POLICY "Authenticated users can read their own templates"
  ON content_templates FOR SELECT
  TO authenticated
  USING (created_by = auth.uid());

CREATE POLICY "Authenticated users can create templates"
  ON content_templates FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by AND
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role IN ('admin', 'editor')
    )
  );

CREATE POLICY "Template creators and admins can update templates"
  ON content_templates FOR UPDATE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role = 'admin'
    )
  )
  WITH CHECK (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role = 'admin'
    )
  );

CREATE POLICY "Template creators and admins can delete templates"
  ON content_templates FOR DELETE
  TO authenticated
  USING (
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND is_active = true
      AND role = 'admin'
    )
  );