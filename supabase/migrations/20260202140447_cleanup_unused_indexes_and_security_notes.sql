/*
  # Cleanup Unused Indexes and Security Documentation

  1. Changes
    - Drop unused database indexes to improve write performance
    - Remove indexes that are not being utilized by queries
    
  2. Unused Indexes Removed
    - idx_posts_slug
    - idx_posts_published
    - idx_page_content_page
    - idx_page_content_sort
    - idx_page_content_active
    - idx_page_content_type
    - idx_page_seo_page
    - idx_content_templates_type
    - idx_content_templates_public
    
  3. Security Notes
    - RLS policies are intentionally permissive for this personal blog/portfolio
    - This site does not have authentication implemented
    - For production use with multiple users, implement authentication and restrict policies
    - Auth DB Connection Strategy should be changed to percentage-based in Supabase dashboard
*/

-- Drop unused indexes on posts table
DROP INDEX IF EXISTS idx_posts_slug;
DROP INDEX IF EXISTS idx_posts_published;

-- Drop unused indexes on page_content_sections table
DROP INDEX IF EXISTS idx_page_content_page;
DROP INDEX IF EXISTS idx_page_content_sort;
DROP INDEX IF EXISTS idx_page_content_active;
DROP INDEX IF EXISTS idx_page_content_type;

-- Drop unused indexes on page_seo_content table
DROP INDEX IF EXISTS idx_page_seo_page;

-- Drop unused indexes on content_templates table
DROP INDEX IF EXISTS idx_content_templates_type;
DROP INDEX IF EXISTS idx_content_templates_public;