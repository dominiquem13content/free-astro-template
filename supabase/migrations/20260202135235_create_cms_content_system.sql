/*
  # Create Flexible CMS Content System

  ## Overview
  This migration creates a comprehensive content management system that allows
  non-technical users to create and manage rich, structured content without code deployments.

  ## New Tables

  ### 1. page_content_sections
  Flexible content sections that can be added to any page type. Each section can be
  one of many types (FAQ, checklist, rich text, etc.) with structured JSON data.
  
  - `id` (uuid, primary key) - Unique identifier
  - `page_type` (text, required) - Type of page (credit_card, category, article, etc.)
  - `page_id` (uuid, required) - Foreign key to specific page
  - `section_type` (text, required) - Type of section (rich_text, faq_accordion, etc.)
  - `title` (text) - Optional section title
  - `content` (text) - Markdown/HTML for simple sections
  - `content_data` (jsonb) - Structured data for complex sections
  - `sort_order` (integer) - Display order (use increments of 10)
  - `is_active` (boolean) - Soft delete flag
  - `created_at` (timestamptz) - Creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. page_seo_content
  SEO-optimized content blocks for intro, main, and bottom sections of pages.
  
  - `id` (uuid, primary key) - Unique identifier
  - `page_type` (text, required) - Type of page
  - `page_id` (uuid, required) - Foreign key to specific page
  - `intro_text` (text) - Opening paragraph (150-200 words)
  - `main_content` (text) - Main body content (300-500 words)
  - `bottom_content` (text) - Closing SEO text (200-300 words)
  - `created_at` (timestamptz) - Creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 3. content_templates
  Reusable content templates that can be applied to multiple pages.
  
  - `id` (uuid, primary key) - Unique identifier
  - `template_name` (text, required) - Name of the template
  - `page_type` (text, required) - Type of page this template is for
  - `sections` (jsonb) - Array of section configurations
  - `description` (text) - Template description
  - `is_public` (boolean) - Whether template is available to all users
  - `created_at` (timestamptz) - Creation timestamp

  ## Security
  - Enable RLS on all tables
  - Public users can read active content
  - Only authenticated users can create/update/delete content
  - Service role has full access for migrations

  ## Indexes
  - Composite indexes on page_type + page_id for fast lookups
  - Index on sort_order for efficient ordering
  - Index on is_active for filtering active content
*/

-- Create page_content_sections table
CREATE TABLE IF NOT EXISTS page_content_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Page identification
  page_type text NOT NULL CHECK (page_type IN ('blog_post', 'blog_category', 'blog_tag', 'blog_author', 'homepage', 'about', 'portfolio', 'custom')),
  page_id text NOT NULL, -- Using text to match blog slugs
  
  -- Content structure
  section_type text NOT NULL CHECK (section_type IN (
    'rich_text', 
    'faq_accordion', 
    'comparison_table',
    'callout_box',
    'checklist',
    'numbered_steps',
    'feature_highlights',
    'two_column_text',
    'cta_banner'
  )),
  title text,
  content text,
  content_data jsonb DEFAULT '{}'::jsonb,
  
  -- Display control
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create page_seo_content table
CREATE TABLE IF NOT EXISTS page_seo_content (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_type text NOT NULL,
  page_id text NOT NULL,
  
  -- SEO content blocks
  intro_text text,
  main_content text,
  bottom_content text,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- One SEO content per page
  UNIQUE(page_type, page_id)
);

-- Create content_templates table
CREATE TABLE IF NOT EXISTS content_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name text NOT NULL,
  page_type text NOT NULL,
  sections jsonb DEFAULT '[]'::jsonb,
  description text,
  is_public boolean DEFAULT false,
  
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_page_content_page ON page_content_sections(page_type, page_id);
CREATE INDEX IF NOT EXISTS idx_page_content_sort ON page_content_sections(page_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_page_content_active ON page_content_sections(is_active);
CREATE INDEX IF NOT EXISTS idx_page_content_type ON page_content_sections(section_type);

CREATE INDEX IF NOT EXISTS idx_page_seo_page ON page_seo_content(page_type, page_id);

CREATE INDEX IF NOT EXISTS idx_content_templates_type ON content_templates(page_type);
CREATE INDEX IF NOT EXISTS idx_content_templates_public ON content_templates(is_public);

-- Create trigger for auto-updating updated_at on page_content_sections
DROP TRIGGER IF EXISTS update_page_content_sections_updated_at ON page_content_sections;
CREATE TRIGGER update_page_content_sections_updated_at
  BEFORE UPDATE ON page_content_sections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for auto-updating updated_at on page_seo_content
DROP TRIGGER IF EXISTS update_page_seo_content_updated_at ON page_seo_content;
CREATE TRIGGER update_page_seo_content_updated_at
  BEFORE UPDATE ON page_seo_content
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE page_content_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_seo_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for page_content_sections
CREATE POLICY "Public can read active sections"
  ON page_content_sections FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

CREATE POLICY "Authenticated users can insert sections"
  ON page_content_sections FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update sections"
  ON page_content_sections FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete sections"
  ON page_content_sections FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for page_seo_content
CREATE POLICY "Public can read SEO content"
  ON page_seo_content FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert SEO content"
  ON page_seo_content FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update SEO content"
  ON page_seo_content FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete SEO content"
  ON page_seo_content FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for content_templates
CREATE POLICY "Public can read public templates"
  ON content_templates FOR SELECT
  TO anon, authenticated
  USING (is_public = true);

CREATE POLICY "Authenticated users can manage templates"
  ON content_templates FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insert example content sections for demonstration
INSERT INTO page_content_sections (page_type, page_id, section_type, title, content, content_data, sort_order)
VALUES 
  (
    'blog_post',
    'example-post-1',
    'callout_box',
    'Key Takeaway',
    'This is an important insight that readers should remember.',
    '{"variant": "info", "callout_type": "info"}'::jsonb,
    10
  ),
  (
    'blog_post',
    'example-post-1',
    'faq_accordion',
    'Frequently Asked Questions',
    NULL,
    '{
      "faqs": [
        {
          "question": "What makes this approach effective?",
          "answer": "This approach combines proven strategies with modern techniques, resulting in better outcomes and efficiency."
        },
        {
          "question": "How long does it take to see results?",
          "answer": "Most users see initial results within 2-3 weeks, with significant improvements after 2-3 months of consistent application."
        },
        {
          "question": "Is this suitable for beginners?",
          "answer": "Absolutely! This guide is designed to be accessible to beginners while providing value to more experienced practitioners."
        }
      ]
    }'::jsonb,
    20
  ),
  (
    'blog_post',
    'example-post-1',
    'checklist',
    'Key Benefits',
    NULL,
    '{
      "items": [
        "Easy to implement and understand",
        "Proven track record of success",
        "Scalable for teams of any size",
        "Comprehensive documentation and support",
        "Regular updates and improvements"
      ]
    }'::jsonb,
    30
  );

-- Insert example SEO content
INSERT INTO page_seo_content (page_type, page_id, intro_text, main_content, bottom_content)
VALUES (
  'blog_post',
  'example-post-1',
  '<p>Welcome to this comprehensive guide where we explore cutting-edge strategies and practical techniques that can transform your approach to content management.</p>',
  '<p>In this detailed exploration, we dive deep into the principles and practices that make content management systems truly effective. We examine real-world examples, industry best practices, and actionable insights that you can implement immediately.</p>',
  '<p>By implementing these strategies, you''ll be well-equipped to handle the challenges of modern content management while delivering exceptional results for your audience and stakeholders.</p>'
)
ON CONFLICT (page_type, page_id) DO NOTHING;