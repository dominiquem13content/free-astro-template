import { createClient } from '@supabase/supabase-js';

const getEnvVar = (key: string): string => {
  if (typeof import.meta.env !== 'undefined') {
    return import.meta.env[key] || import.meta.env[`VITE_${key.replace('PUBLIC_', '')}`] || '';
  }

  if (typeof process !== 'undefined' && process.env) {
    return process.env[key] || process.env[`VITE_${key.replace('PUBLIC_', '')}`] || '';
  }

  return '';
};

const supabaseUrl = getEnvVar('PUBLIC_SUPABASE_URL');
const supabaseAnonKey = getEnvVar('PUBLIC_SUPABASE_ANON_KEY');

if (!supabaseUrl) {
  throw new Error(
    'Missing Supabase URL. Please set PUBLIC_SUPABASE_URL in your .env file.'
  );
}

if (!supabaseAnonKey) {
  throw new Error(
    'Missing Supabase anonymous key. Please set PUBLIC_SUPABASE_ANON_KEY in your .env file.'
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false,
  },
});

export interface Author {
  id: string;
  name: string;
  email: string;
  bio: string | null;
  avatar_url: string | null;
  slug: string;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  created_at: string;
}

export interface Tag {
  id: string;
  name: string;
  slug: string;
  created_at: string;
}

export interface Post {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt: string | null;
  hero_image: string | null;
  meta_title: string | null;
  meta_description: string | null;
  author_id: string;
  category_id: string | null;
  published: boolean;
  published_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface PostWithRelations extends Post {
  author?: Author;
  category?: Category;
  tags?: Tag[];
}
