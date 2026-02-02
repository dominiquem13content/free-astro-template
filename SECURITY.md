# Security Documentation

## Overview

This application implements production-level security measures to protect the CMS and user data. All security features follow industry best practices and OWASP guidelines.

## Authentication & Authorization

### Supabase Authentication

The application uses Supabase Auth with email/password authentication:

- **Email/Password Login**: Secure authentication with bcrypt password hashing
- **Session Management**: Secure HTTP-only cookies for token storage
- **Token Refresh**: Automatic token refresh for seamless user experience
- **Password Requirements**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number

### User Roles

Three role levels control access to features:

1. **Viewer** (default for new users)
   - Can read content
   - Cannot access CMS admin
   - Cannot modify any data

2. **Editor**
   - Can create, read, and update content
   - Can access CMS admin
   - Can manage their own content
   - Can modify content created by others

3. **Admin**
   - Full access to all features
   - Can delete any content
   - Can manage user roles (via SQL)
   - Can access all admin features

### Protected Routes

The following routes require authentication:

- `/cms-admin` - CMS admin interface (Editor/Admin only)
- `/admin` - General admin pages (Editor/Admin only)

Unauthenticated users are redirected to `/login`.

## Database Security

### Row Level Security (RLS)

All database tables have RLS enabled with restrictive policies:

#### User Profiles Table

- **Read**: Anyone can read active user profiles (for attribution)
- **Insert**: Users can only create their own profile during signup
- **Update**: Users can only update their own profile, excluding role and active status
- **Delete**: Not allowed (use `is_active` flag instead)

#### Content Tables (page_content_sections, page_seo_content, content_templates)

- **Read**: Public can read active/published content
- **Insert**: Only authenticated Editor/Admin users can create
- **Update**: Creators can update their own content; Editors/Admins can update any content
- **Delete**: Creators can delete their own content; Admins can delete any content

### Ownership Tracking

All CMS content includes ownership tracking:

- `created_by` - UUID of the user who created the content
- `updated_by` - UUID of the user who last updated the content
- These fields are automatically set and cannot be manually changed

### Automatic Profile Creation

When a new user signs up via Supabase Auth, a trigger automatically creates their user profile with:

- Default role: `viewer`
- Active status: `true`
- Email and name from auth data

## Session Security

### Cookie Configuration

Authentication tokens are stored in secure HTTP-only cookies:

- **httpOnly**: `true` - Prevents JavaScript access to cookies
- **secure**: `true` (production) - Requires HTTPS
- **sameSite**: `lax` - CSRF protection
- **maxAge**: 7 days - Auto-expire after one week
- **path**: `/` - Available site-wide

### Token Management

- Access tokens are validated on every protected request
- Expired tokens trigger automatic logout and redirect to login
- Refresh tokens enable seamless session renewal
- Invalid tokens clear cookies and redirect to login

## Security Headers

### Response Headers (All Environments)

The application sets security headers on all responses:

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### Content Security Policy (Production)

On Netlify deployments, additional CSP headers prevent XSS attacks:

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self' data:;
  connect-src 'self' https://*.supabase.co wss://*.supabase.co;
  frame-ancestors 'none';
```

## Input Validation & Sanitization

### Server-Side Validation

All form inputs are validated server-side before processing:

- **Email validation**: RFC-compliant email format
- **Password strength**: Enforced complexity requirements
- **Page type/section type**: Whitelist validation
- **UUID validation**: Proper format checking
- **Content length**: Maximum size limits
- **JSON validation**: Syntax and structure checking

### Sanitization Functions

The application includes comprehensive sanitization utilities:

- `sanitizeHtml()` - Escapes HTML special characters
- `sanitizeString()` - Removes control characters
- `sanitizeJsonData()` - Recursively sanitizes JSON objects
- `preventSqlInjection()` - Removes SQL injection characters

### Client-Side Validation

Client-side validation provides immediate user feedback:

- Required field checking
- Format validation (email, password)
- Real-time password strength indicator
- JSON syntax validation in CMS editor

## CSRF Protection

Protection against Cross-Site Request Forgery:

- **SameSite Cookies**: Set to `lax` to prevent CSRF
- **Origin Validation**: Middleware validates request origin
- **POST-only Mutations**: All data changes require POST requests

## Rate Limiting

For production deployments, implement rate limiting:

### Recommended Limits

- **Login endpoint**: 5 attempts per 15 minutes per IP
- **Registration**: 3 accounts per hour per IP
- **API endpoints**: 100 requests per minute per user
- **CMS operations**: 60 requests per minute per user

### Implementation Options

1. **Netlify Edge Functions**: Use edge functions for rate limiting
2. **Supabase Edge Functions**: Implement custom rate limiting
3. **Third-party services**: Cloudflare, AWS WAF, etc.

## Environment Variables

### Required Variables

```env
PUBLIC_SUPABASE_URL=your_supabase_project_url
PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Security Notes

- Never commit `.env` to version control
- Use environment-specific configurations
- Rotate keys regularly
- Keep service role key secure (never expose to client)

## Deployment Security

### Pre-Deployment Checklist

- [ ] All environment variables configured
- [ ] HTTPS enabled
- [ ] Security headers configured
- [ ] RLS policies tested
- [ ] Authentication flows tested
- [ ] Input validation verified
- [ ] Error messages sanitized (no sensitive info)
- [ ] Rate limiting configured
- [ ] Database backups enabled

### Post-Deployment

1. **Monitor Authentication**: Watch for failed login attempts
2. **Review RLS Policies**: Ensure no data leaks
3. **Check Logs**: Monitor for suspicious activity
4. **Update Dependencies**: Regular security patches
5. **Audit User Access**: Review user roles periodically

## First User Setup

The first user to register will have `viewer` role. To promote to admin:

1. Register the first user account via `/register`
2. Connect to Supabase SQL Editor
3. Run the following SQL:

```sql
UPDATE user_profiles
SET role = 'admin'
WHERE email = 'your-email@example.com';
```

4. Refresh the page to see admin access

## Password Reset

Users can reset forgotten passwords:

1. Visit `/login` and click "Forgot Password" (if implemented)
2. Enter email address
3. Check email for reset link
4. Follow link to set new password

Currently, password reset UI is not implemented but the backend functions exist in `/src/lib/auth.ts`.

## Security Incident Response

If you suspect a security breach:

1. **Immediate Actions**:
   - Rotate all API keys and tokens
   - Review recent database activity
   - Check for unauthorized user accounts
   - Disable affected accounts

2. **Investigation**:
   - Review application logs
   - Check Supabase auth logs
   - Analyze database audit trail
   - Identify affected data

3. **Remediation**:
   - Patch vulnerabilities
   - Reset passwords for affected users
   - Notify users if data was compromised
   - Update security policies

## Known Limitations

1. **No 2FA**: Two-factor authentication not implemented
2. **No rate limiting**: Must be configured separately
3. **Password reset UI**: Backend ready, frontend not built
4. **Session timeout**: Fixed 7-day expiry, not configurable
5. **No IP allowlisting**: All IPs can access admin (behind auth)

## Future Security Enhancements

### Short Term

- [ ] Implement password reset UI
- [ ] Add rate limiting middleware
- [ ] Session activity logging
- [ ] Failed login tracking and alerts
- [ ] Email verification on signup

### Long Term

- [ ] Two-factor authentication (2FA)
- [ ] Single Sign-On (SSO) support
- [ ] Advanced audit logging
- [ ] Automated security scanning
- [ ] Intrusion detection system

## Security Resources

- [Supabase Security Best Practices](https://supabase.com/docs/guides/platform/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do not** open a public GitHub issue
2. Email security concerns to the project maintainer
3. Include detailed reproduction steps
4. Allow time for patch development before public disclosure

## Compliance

This security implementation addresses:

- OWASP Top 10 vulnerabilities
- CWE/SANS Top 25 Most Dangerous Software Errors
- General Data Protection Regulation (GDPR) basics
- Basic PCI-DSS requirements (if handling payments)

## Security Testing

Regular security testing should include:

1. **Authentication Testing**:
   - Password strength enforcement
   - Session management
   - Token expiration
   - Logout functionality

2. **Authorization Testing**:
   - Role-based access control
   - Privilege escalation attempts
   - Direct object references

3. **Input Validation**:
   - SQL injection attempts
   - XSS payload testing
   - Command injection
   - Path traversal

4. **Session Management**:
   - Cookie security flags
   - Token rotation
   - Concurrent sessions
   - Session timeout

## Updates

This security documentation should be reviewed and updated:

- After any security-related code changes
- Following security incidents
- When new features are added
- At least quarterly for general review

---

**Last Updated**: 2026-02-02
**Security Version**: 1.0.0
