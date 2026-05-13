# 🔒 Security

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Security Headers (Helmet)

Helmet is applied as the **second** global middleware (after request ID). It sets:

| Header | Value | Purpose |
|--------|-------|---------|
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `X-XSS-Protection` | `0` | Disable legacy XSS filter (rely on CSP) |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Force HTTPS |
| `Content-Security-Policy` | Restrictive policy | Prevent XSS/injection |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Control referrer info |

---

## 2. CORS Configuration

```typescript
import cors from 'cors';
import { config } from '@config/index.js';

const corsOptions: cors.CorsOptions = {
  origin: (origin, callback) => {
    const allowed = config.CORS_ORIGINS.split(',').map((o) => o.trim());
    if (!origin || allowed.includes('*') || allowed.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: config.CORS_CREDENTIALS,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
  exposedHeaders: ['X-Request-Id', 'RateLimit-Limit', 'RateLimit-Remaining'],
  maxAge: 86400, // 24 hours preflight cache
};
```

---

## 3. Input Sanitization

### 3.1 SQL Injection

- **Prisma** uses parameterized queries by default — SQL injection is prevented at the ORM level.
- **Never** use `prisma.$queryRaw` with string interpolation.

### 3.2 XSS Prevention

- All user input is validated via Zod with `.trim()` and length limits.
- HTML content is escaped before storage if the field allows rich text.
- Helmet's CSP header provides browser-level protection.

### 3.3 NoSQL Injection

- Not applicable — PostgreSQL only (no MongoDB/NoSQL).

---

## 4. Authentication Security

See `_authentication.md` for full details. Key points:

- Authentication is **fully delegated to Clerk** — no in-house auth.
- Clerk handles JWT issuance, session management, MFA, OAuth/SSO.
- Backend verifies Clerk JWTs via `@clerk/express` SDK (JWKS-based).
- No passwords stored in our database — Clerk manages credentials.
- User data synced from Clerk to local DB via middleware and webhooks.
- Webhook signatures verified using `svix`.

---

## 5. Data Protection

| Practice | Implementation |
|----------|---------------|
| Passwords | **Not stored** — Clerk handles all credential management |
| Tokens | Clerk JWTs verified server-side; never logged or stored |
| PII | Minimal collection — only what’s needed |
| Audit logs | Sensitive fields redacted before storage |
| Error responses | Never expose internal details (DB columns, paths) |

---

## 6. Dependency Security

- Run `npm audit` in CI pipeline — fail on **high** or **critical** vulnerabilities.
- Pin major versions of all dependencies.
- Review `package-lock.json` changes in PRs.
- No eval, no dynamic requires, no `Function()` constructors.

---

## 7. Security Checklist

- [ ] Helmet enabled with strict CSP
- [ ] CORS configured with explicit origins (no `*` in production)
- [ ] Rate limiting on all endpoints
- [ ] Clerk authentication configured with `@clerk/express`
- [ ] Clerk webhook endpoint secured with `svix` signature verification
- [ ] No passwords stored in application database
- [ ] `CLERK_SECRET_KEY` never exposed to frontend
- [ ] All input validated with Zod
- [ ] Error messages generic in production
- [ ] Audit trail on all write operations
- [ ] `npm audit` passing in CI
- [ ] No secrets in source code or Docker images

---

## 8. Rules

1. **Never** disable Helmet in production.
2. **Never** use `CORS_ORIGINS=*` in production.
3. **Never** log sensitive data (tokens, passwords, full emails).
4. **Never** expose stack traces in production responses.
5. **Always** validate and sanitize input at the edge.
6. **Always** use parameterized queries (Prisma handles this).
7. Run security audits as part of CI — not optional.
