import { defineMiddleware } from 'astro:middleware';
import { supabase } from './lib/supabase';

export const onRequest = defineMiddleware(async (context, next) => {
  const protectedRoutes = ['/cms-admin', '/admin'];
  const isProtectedRoute = protectedRoutes.some(route =>
    context.url.pathname.startsWith(route)
  );

  if (isProtectedRoute) {
    const accessToken = context.cookies.get('sb-access-token')?.value;
    const refreshToken = context.cookies.get('sb-refresh-token')?.value;

    if (!accessToken) {
      return context.redirect('/login');
    }

    try {
      const { data: { user }, error } = await supabase.auth.getUser(accessToken);

      if (error || !user) {
        context.cookies.delete('sb-access-token', { path: '/' });
        context.cookies.delete('sb-refresh-token', { path: '/' });
        return context.redirect('/login');
      }

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('role, is_active')
        .eq('id', user.id)
        .maybeSingle();

      if (!profile || !profile.is_active) {
        return context.redirect('/login?error=inactive');
      }

      if (profile.role === 'viewer') {
        return context.redirect('/login?error=unauthorized');
      }

      context.locals.user = user;
      context.locals.profile = profile;

    } catch (err) {
      console.error('Auth middleware error:', err);
      return context.redirect('/login');
    }
  }

  const response = await next();

  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  response.headers.set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

  return response;
});
