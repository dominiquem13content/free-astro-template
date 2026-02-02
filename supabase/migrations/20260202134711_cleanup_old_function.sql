/*
  # Cleanup Old Function Version

  ## Changes
  - Drop the old insecure version of update_updated_at_column function
  - This removes the duplicate function without security settings
*/

-- Drop the old function version (the one without SECURITY DEFINER and search_path)
-- Keep only the secure version created in the previous migration
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Recreate the secure version
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Recreate triggers that depend on this function
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
