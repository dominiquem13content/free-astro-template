import type { AstroCookies } from 'astro';
import { supabase } from './supabase';

export interface UserProfile {
  id: string;
  email: string;
  full_name: string | null;
  role: 'admin' | 'editor' | 'viewer';
  is_active: boolean;
}

export async function setAuthCookies(cookies: AstroCookies, accessToken: string, refreshToken: string) {
  const maxAge = 60 * 60 * 24 * 7;

  cookies.set('sb-access-token', accessToken, {
    path: '/',
    maxAge,
    httpOnly: true,
    secure: import.meta.env.PROD,
    sameSite: 'lax'
  });

  cookies.set('sb-refresh-token', refreshToken, {
    path: '/',
    maxAge,
    httpOnly: true,
    secure: import.meta.env.PROD,
    sameSite: 'lax'
  });
}

export function clearAuthCookies(cookies: AstroCookies) {
  cookies.delete('sb-access-token', { path: '/' });
  cookies.delete('sb-refresh-token', { path: '/' });
}

export async function getCurrentUser(cookies: AstroCookies) {
  const accessToken = cookies.get('sb-access-token')?.value;

  if (!accessToken) {
    return null;
  }

  try {
    const { data: { user }, error } = await supabase.auth.getUser(accessToken);

    if (error || !user) {
      return null;
    }

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', user.id)
      .maybeSingle();

    if (!profile) {
      return null;
    }

    return {
      user,
      profile: profile as UserProfile
    };
  } catch (err) {
    console.error('Error getting current user:', err);
    return null;
  }
}

export async function signUp(email: string, password: string, fullName?: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName
      }
    }
  });

  return { data, error };
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  return { data, error };
}

export async function signOut() {
  const { error } = await supabase.auth.signOut();
  return { error };
}

export async function resetPassword(email: string) {
  const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${import.meta.env.SITE}/auth/reset-password`
  });

  return { data, error };
}

export async function updatePassword(accessToken: string, newPassword: string) {
  const { data, error } = await supabase.auth.updateUser({
    password: newPassword
  });

  return { data, error };
}

export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validatePassword(password: string): { valid: boolean; message?: string } {
  if (password.length < 8) {
    return { valid: false, message: 'Password must be at least 8 characters long' };
  }

  if (!/[A-Z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one uppercase letter' };
  }

  if (!/[a-z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one lowercase letter' };
  }

  if (!/[0-9]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one number' };
  }

  return { valid: true };
}
