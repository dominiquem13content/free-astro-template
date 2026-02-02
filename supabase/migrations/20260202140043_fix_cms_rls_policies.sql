/*
  # Fix CMS RLS Policies for Anonymous Access

  1. Changes
    - Allow anonymous users to read ALL sections (not just active ones) for CMS management
    - Allow anonymous users to insert, update, and delete sections
    - This enables the CMS admin interface to work without authentication
  
  2. Security Note
    - For production use, you should add authentication to the CMS admin page
    - These permissive policies are suitable for development/personal sites
    - Consider restricting access via application-level authentication or IP restrictions
*/

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Public can read active sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can insert sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can update sections" ON page_content_sections;
DROP POLICY IF EXISTS "Authenticated users can delete sections" ON page_content_sections;

-- Create new permissive policies for CMS management
CREATE POLICY "Allow read all sections"
  ON page_content_sections
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow insert sections"
  ON page_content_sections
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow update sections"
  ON page_content_sections
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow delete sections"
  ON page_content_sections
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- Apply same fixes to page_seo_content table
DROP POLICY IF EXISTS "Authenticated users can read SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can insert SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can update SEO content" ON page_seo_content;
DROP POLICY IF EXISTS "Authenticated users can delete SEO content" ON page_seo_content;

CREATE POLICY "Allow read SEO content"
  ON page_seo_content
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow insert SEO content"
  ON page_seo_content
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow update SEO content"
  ON page_seo_content
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow delete SEO content"
  ON page_seo_content
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- Apply same fixes to content_templates table
DROP POLICY IF EXISTS "Public can read public templates" ON content_templates;
DROP POLICY IF EXISTS "Authenticated users can manage templates" ON content_templates;
DROP POLICY IF EXISTS "Authenticated users can insert templates" ON content_templates;
DROP POLICY IF EXISTS "Authenticated users can update templates" ON content_templates;
DROP POLICY IF EXISTS "Authenticated users can delete templates" ON content_templates;

CREATE POLICY "Allow read templates"
  ON content_templates
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow insert templates"
  ON content_templates
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow update templates"
  ON content_templates
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow delete templates"
  ON content_templates
  FOR DELETE
  TO anon, authenticated
  USING (true);