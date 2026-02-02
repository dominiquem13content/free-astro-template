import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: false,
    detectSessionInUrl: false
  }
});

export async function getSession() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  return session;
}

export async function refreshSession() {
  const { data: { session }, error } = await supabaseClient.auth.refreshSession();

  if (error) {
    console.error('Session refresh error:', error);
    return null;
  }

  return session;
}
