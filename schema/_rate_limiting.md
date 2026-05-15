# 🚦 Rate Limiting

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Library | `express-rate-limit` |
| Store (dev) | In-memory |
| Store (prod) | Redis (via `rate-limit-redis`) |
| Identifier | IP address (+ user ID when authenticated) |

---

## 2. Rate Limit Tiers

| Tier | Window | Max Requests | Applied To |
|------|--------|-------------|-----------|
| **Global** | 15 min | 100 | All routes |
| **Auth** | 15 min | 10 | `/auth/login`, `/auth/register` |
| **Password Reset** | 1 hour | 3 | `/auth/forgot-password` |
| **API (authenticated)** | 1 min | 60 | Authenticated endpoints |

---

## 3. Implementation

```typescript
// src/common/middleware/rate-limiter.middleware.ts
import rateLimit from 'express-rate-limit';
import { config } from '@config/index.js';

export const globalRateLimiter = rateLimit({
  windowMs: config.RATE_LIMIT_WINDOW_MS,
  max: config.RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests, please try again later',
      details: null,
    },
  },
});

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many authentication attempts',
      details: null,
    },
  },
});

export const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
});
```

---

## 4. Response Headers

When rate limiting is active, these headers are included:

| Header | Description |
|--------|-------------|
| `RateLimit-Limit` | Max requests in window |
| `RateLimit-Remaining` | Remaining requests |
| `RateLimit-Reset` | Seconds until window resets |
| `Retry-After` | Seconds to wait (when limited) |

---

## 5. Rules

1. **Global** limiter applies to all routes — registered first in middleware stack.
2. **Auth** limiter applies **in addition to** the global limiter on auth routes.
3. Rate limit errors return **429** with the standard error envelope format.
4. In production, use Redis store for distributed rate limiting.
5. Rate limit error response must match the `_api_response.md` error format.
