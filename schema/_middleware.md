# ⚙️ Middleware Stack

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Middleware Execution Order

Middleware **MUST** be registered in this exact order. Changing the order can introduce security vulnerabilities.

```
┌──────────────────────────────────────┐
│ 1. Request ID Injection              │  ← Assigns unique ID to every request
│ 2. Helmet (Security Headers)         │  ← Sets security HTTP headers
│ 3. CORS                              │  ← Cross-origin resource sharing
│ 4. Body Parser (JSON)                │  ← Parse JSON request body
│ 5. Body Parser (URL-encoded)         │  ← Parse form data
│ 6. Clerk Middleware                  │  ← Parses & verifies Clerk JWT
│ 7. Request Logger                    │  ← Log incoming requests
│ 8. Rate Limiter (Global)             │  ← Global rate limiting
│ 9. API Routes                        │  ← Route handlers
│ 10. 404 Handler                      │  ← Catch unmatched routes
│ 11. Global Error Handler             │  ← Centralized error handling
└──────────────────────────────────────┘
```

---

## 2. Global Middleware

### 2.1 Request ID

```typescript
// src/common/middleware/request-id.middleware.ts
import { randomUUID } from 'node:crypto';
import { Request, Response, NextFunction } from 'express';

export const requestIdMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const requestId = (req.headers['x-request-id'] as string) ?? randomUUID();
  req.requestId = requestId;
  res.setHeader('X-Request-Id', requestId);
  next();
};
```

### 2.2 Request Logger

```typescript
// src/common/middleware/request-logger.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { logger } from '@config/logger.js';

export const requestLoggerMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info('request completed', {
      requestId: req.requestId,
      method: req.method,
      path: req.originalUrl,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.get('user-agent'),
    });
  });

  next();
};
```

### 2.3 Not Found Handler

```typescript
// src/common/middleware/not-found.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { NotFoundError } from '@common/errors/index.js';

export const notFoundMiddleware = (_req: Request, _res: Response, next: NextFunction): void => {
  next(new NotFoundError('Route not found'));
};
```

---

## 3. Route-Level Middleware

These are applied per-route, not globally:

| Middleware | Purpose | Applied To |
|-----------|---------|-----------|
| `authGuard` | Clerk JWT verification (`requireAuth()`) | All protected routes |
| `requirePermission(...)` | RBAC permission check | Routes needing specific perms |
| `validate(schema)` | Zod request validation | Routes with body/query/params |
| `uploadMiddleware` | Multer file upload | File upload routes |
| `rateLimiter(opts)` | Stricter rate limits | Auth endpoints, sensitive routes |

### Route-Level Order

```typescript
router.post(
  '/',
  authGuard,                        // 1. Authenticate
  requirePermission('user:create'), // 2. Authorize
  validate(createUserSchema),       // 3. Validate input
  userController.create,            // 4. Handle request
);
```

---

## 4. App Registration

```typescript
// src/app.ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { clerkMiddleware } from '@clerk/express';
import { config } from '@config/index.js';
import { requestIdMiddleware } from '@common/middleware/request-id.middleware.js';
import { requestLoggerMiddleware } from '@common/middleware/request-logger.middleware.js';
import { globalRateLimiter } from '@common/middleware/rate-limiter.middleware.js';
import { notFoundMiddleware } from '@common/middleware/not-found.middleware.js';
import { errorMiddleware } from '@common/middleware/error.middleware.js';
import { apiRouter } from './routes.js';

export const createApp = () => {
  const app = express();

  // ── Global Middleware (ORDER MATTERS) ──
  app.use(requestIdMiddleware);
  app.use(helmet());
  app.use(cors({
    origin: config.CORS_ORIGINS.split(','),
    credentials: config.CORS_CREDENTIALS,
  }));
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(clerkMiddleware());        // ← Clerk replaces cookie-parser
  app.use(requestLoggerMiddleware);
  app.use(globalRateLimiter);

  // ── Routes ──
  app.use(config.API_PREFIX, apiRouter);

  // ── Error Handling ──
  app.use(notFoundMiddleware);
  app.use(errorMiddleware);

  return app;
};
```

---

## 5. Rules

1. **Never** add global middleware after the route registration.
2. **Never** skip the auth guard on protected routes — routes are protected by default.
3. Validation middleware runs **after** auth guards — no wasted validation on unauthenticated requests.
4. The error middleware must always be the **last** middleware registered.
5. Custom middleware files go in `src/common/middleware/` with the `.middleware.ts` suffix.
