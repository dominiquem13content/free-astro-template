/*
  # Final Function Cleanup

  ## Changes
  - Completely remove all versions of the function
  - Recreate only the secure version with proper settings
*/

-- Drop all triggers first
DROP TRIGGER IF EXISTS update_authors_updated_at ON authors;
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;

-- Drop all function versions by signature
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Create the secure version only
CREATE FUNCTION update_updated_at_column()
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

-- Recreate triggers
CREATE TRIGGER update_authors_updated_at
  BEFORE UPDATE ON authors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
