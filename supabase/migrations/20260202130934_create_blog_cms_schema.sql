/*
  # Blog CMS Database Schema

  ## Overview
  Complete database schema for blog content management system with authors, posts, categories, and tags.

  ## New Tables
  
  ### 1. authors
  - `id` (uuid, primary key) - Unique identifier for each author
  - `name` (text, required) - Author's full name
  - `email` (text, unique) - Author's email address
  - `bio` (text) - Author biography
  - `avatar_url` (text) - URL to author's profile picture
  - `slug` (text, unique, required) - URL-friendly identifier
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. categories
  - `id` (uuid, primary key) - Unique identifier for each category
  - `name` (text, required) - Category name
  - `slug` (text, unique, required) - URL-friendly identifier
  - `description` (text) - Category description
  - `created_at` (timestamptz) - Record creation timestamp

  ### 3. tags
  - `id` (uuid, primary key) - Unique identifier for each tag
  - `name` (text, required) - Tag name
  - `slug` (text, unique, required) - URL-friendly identifier
  - `created_at` (timestamptz) - Record creation timestamp

  ### 4. posts
  - `id` (uuid, primary key) - Unique identifier for each post
  - `title` (text, required) - Post title
  - `slug` (text, unique, required) - URL-friendly identifier
  - `content` (text, required) - Post content in markdown format
  - `excerpt` (text) - Short summary of the post
  - `hero_image` (text) - URL to hero/featured image
  - `meta_title` (text) - SEO meta title
  - `meta_description` (text) - SEO meta description
  - `author_id` (uuid, foreign key) - Reference to authors table
  - `category_id` (uuid, foreign key) - Reference to categories table
  - `published` (boolean, default false) - Publication status
  - `published_at` (timestamptz) - Publication timestamp
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 5. post_tags
  - `post_id` (uuid, foreign key) - Reference to posts table
  - `tag_id` (uuid, foreign key) - Reference to tags table
  - Primary key: (post_id, tag_id) - Composite key for many-to-many relationship

  ## Security
  - Enable RLS on all tables
  - Allow public read access to all tables
  - Restrictive policies for authenticated operations (to be added later with auth)

  ## Indexes
  - Indexes on slug columns for fast lookups
  - Indexes on foreign keys for efficient joins
  - Index on published_at for chronological queries

  ## Seed Data
  - Sample authors, categories, and tags for immediate use
*/

-- Create authors table
CREATE TABLE IF NOT EXISTS authors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  bio text,
  avatar_url text,
  slug text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Create tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  content text NOT NULL,
  excerpt text,
  hero_image text,
  meta_title text,
  meta_description text,
  author_id uuid REFERENCES authors(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  published boolean DEFAULT false,
  published_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create post_tags junction table
CREATE TABLE IF NOT EXISTS post_tags (
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_authors_slug ON authors(slug);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);
CREATE INDEX IF NOT EXISTS idx_tags_slug ON tags(slug);
CREATE INDEX IF NOT EXISTS idx_posts_slug ON posts(slug);
CREATE INDEX IF NOT EXISTS idx_posts_author_id ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_category_id ON posts(category_id);
CREATE INDEX IF NOT EXISTS idx_posts_published ON posts(published);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON posts(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX IF NOT EXISTS idx_post_tags_tag_id ON post_tags(tag_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for auto-updating updated_at
DROP TRIGGER IF EXISTS update_authors_updated_at ON authors;
CREATE TRIGGER update_authors_updated_at
  BEFORE UPDATE ON authors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access to authors"
  ON authors FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public read access to categories"
  ON categories FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public read access to tags"
  ON tags FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public read access to published posts"
  ON posts FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public read access to post_tags"
  ON post_tags FOR SELECT
  TO anon, authenticated
  USING (true);

-- Create policies for public write access (no auth required for this CMS)
CREATE POLICY "Allow public insert to authors"
  ON authors FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public update to authors"
  ON authors FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to authors"
  ON authors FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public insert to categories"
  ON categories FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public update to categories"
  ON categories FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to categories"
  ON categories FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public insert to tags"
  ON tags FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public update to tags"
  ON tags FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to tags"
  ON tags FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public insert to posts"
  ON posts FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public update to posts"
  ON posts FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow public delete to posts"
  ON posts FOR DELETE
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow public insert to post_tags"
  ON post_tags FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow public delete to post_tags"
  ON post_tags FOR DELETE
  TO anon, authenticated
  USING (true);

-- Insert seed data for authors
INSERT INTO authors (name, email, bio, avatar_url, slug)
VALUES 
  ('John Doe', 'john@example.com', 'Senior data analyst and writer specializing in analytics and visualization.', 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg', 'john-doe'),
  ('Jane Smith', 'jane@example.com', 'Content strategist with expertise in technical writing and SEO.', 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg', 'jane-smith')
ON CONFLICT (slug) DO NOTHING;

-- Insert seed data for categories
INSERT INTO categories (name, slug, description)
VALUES 
  ('Data Analysis', 'data-analysis', 'Articles about data analysis techniques and best practices'),
  ('Visualization', 'visualization', 'Data visualization tips and tools'),
  ('Analytics Tools', 'analytics-tools', 'Reviews and guides for analytics platforms'),
  ('Tutorial', 'tutorial', 'Step-by-step guides and how-tos'),
  ('Opinion', 'opinion', 'Thoughts and perspectives on industry trends')
ON CONFLICT (slug) DO NOTHING;

-- Insert seed data for tags
INSERT INTO tags (name, slug)
VALUES 
  ('Data Science', 'data-science'),
  ('SQL', 'sql'),
  ('Python', 'python'),
  ('Tableau', 'tableau'),
  ('Google Analytics', 'google-analytics'),
  ('Business Intelligence', 'business-intelligence'),
  ('Dashboard', 'dashboard'),
  ('Reporting', 'reporting'),
  ('Metrics', 'metrics'),
  ('KPIs', 'kpis')
ON CONFLICT (slug) DO NOTHING;