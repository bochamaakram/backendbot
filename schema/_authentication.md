# 🔑 Authentication (Clerk)

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Provider | [Clerk](https://clerk.com) — managed authentication |
| Method | Clerk-issued JWT (Bearer token) |
| Token verification | `@clerk/express` SDK middleware |
| User management | Clerk Dashboard + API (signup, login, MFA, SSO) |
| Password handling | **Delegated entirely to Clerk** — no passwords in our DB |
| Session management | **Delegated entirely to Clerk** — no refresh tokens in our DB |

> **Why Clerk?** Authentication is a solved problem. Clerk handles signup, login, MFA, OAuth/SSO, session management, email verification, and password resets — all battle-tested and SOC 2 compliant. Our backend only needs to **verify** tokens and **sync** user data.

---

## 2. How It Works

```
┌──────────────────────────────────┐
│  Frontend (SPA / Mobile)         │
│  Uses Clerk's React/JS SDK      │
│  to handle signup, login, MFA   │
│  ┌────────────────────────────┐  │
│  │  Clerk.session.getToken()  │  │
│  └──────────┬─────────────────┘  │
└─────────────┼────────────────────┘
              │  Authorization: Bearer <clerk-jwt>
              ▼
┌──────────────────────────────────┐
│  Express.js Backend              │
│  ┌────────────────────────────┐  │
│  │  clerkMiddleware()         │  │──── Verifies JWT using Clerk's JWKS
│  │  (from @clerk/express)     │  │
│  └──────────┬─────────────────┘  │
│  ┌──────────▼─────────────────┐  │
│  │  requireAuth()             │  │──── Rejects if not authenticated
│  └──────────┬─────────────────┘  │
│  ┌──────────▼─────────────────┐  │
│  │  syncUser middleware       │  │──── Upserts Clerk user → local DB
│  └──────────┬─────────────────┘  │
│  ┌──────────▼─────────────────┐  │
│  │  Controller / Service      │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 3. Clerk JWT Payload

Clerk JWTs include these standard claims (verified automatically by the SDK):

```json
{
  "sub": "user_2abc123...",
  "azp": "https://your-app.com",
  "iss": "https://clerk.your-app.com",
  "exp": 1234568790,
  "iat": 1234567890,
  "nbf": 1234567890,
  "sid": "sess_abc123..."
}
```

Custom claims (role, permissions) are injected via **Clerk's session token customization** (see Section 7).

---

## 4. SDK Setup

### 4.1 Install

```bash
npm install @clerk/express
```

### 4.2 Clerk Middleware (Global)

```typescript
// src/app.ts — registered as global middleware
import { clerkMiddleware } from '@clerk/express';

app.use(clerkMiddleware());
```

This middleware:
- Parses the `Authorization: Bearer <token>` header
- Verifies the JWT signature against Clerk's JWKS endpoint
- Populates `req.auth` with the authenticated session data
- Does **NOT** reject unauthenticated requests (that's `requireAuth()`'s job)

### 4.3 Route Protection with `requireAuth()`

```typescript
import { requireAuth } from '@clerk/express';

// Protect a single route
router.get('/profile', requireAuth(), userController.getProfile);

// Protect all routes in a router
router.use(requireAuth());
```

`requireAuth()` returns a `401` if the request is not authenticated.

---

## 5. Auth Guard Implementation

```typescript
// src/common/guards/auth.guard.ts
import { requireAuth, getAuth } from '@clerk/express';
import { Request, Response, NextFunction } from 'express';
import { UnauthorizedError } from '@common/errors/index.js';

/**
 * Primary auth guard — wraps Clerk's requireAuth().
 * Use this on all protected routes.
 */
export const authGuard = requireAuth({
  signInUrl: undefined, // API-only — no redirect
});

/**
 * Extract the authenticated user's Clerk ID from the request.
 * Call AFTER authGuard has run.
 *
 * @throws UnauthorizedError if no auth context found
 */
export const getClerkUserId = (req: Request): string => {
  const auth = getAuth(req);
  if (!auth?.userId) {
    throw new UnauthorizedError('Authentication required');
  }
  return auth.userId;
};

/**
 * Extract full auth context from Clerk.
 */
export const getClerkAuth = (req: Request) => {
  const auth = getAuth(req);
  if (!auth?.userId) {
    throw new UnauthorizedError('Authentication required');
  }
  return auth;
};
```

---

## 6. User Sync — Clerk → Local DB

Since Clerk owns user identity, we maintain a **local User record** for relational data (roles, audit logs, etc.). The sync happens in two ways:

### 6.1 Sync Middleware (On Request)

```typescript
// src/common/middleware/sync-user.middleware.ts
import { getAuth, clerkClient } from '@clerk/express';
import { Request, Response, NextFunction } from 'express';
import { prisma } from '@config/database.js';
import { logger } from '@config/logger.js';

/**
 * Syncs the Clerk user to the local database on every authenticated request.
 * Creates the user if they don't exist locally.
 * Lightweight — only queries DB, does NOT call Clerk API on every request.
 */
export const syncUserMiddleware = async (
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const auth = getAuth(req);
    if (!auth?.userId) {
      next();
      return;
    }

    // Check if user exists locally
    let user = await prisma.user.findUnique({
      where: { clerkId: auth.userId },
      include: { role: { include: { permissions: true } } },
    });

    if (!user) {
      // First time this Clerk user hits our API — fetch details & create
      const clerkUser = await clerkClient.users.getUser(auth.userId);
      const defaultRole = await prisma.role.findUnique({
        where: { name: 'Viewer' },
      });

      user = await prisma.user.create({
        data: {
          clerkId: auth.userId,
          email: clerkUser.emailAddresses[0]?.emailAddress ?? '',
          firstName: clerkUser.firstName ?? '',
          lastName: clerkUser.lastName ?? '',
          roleId: defaultRole!.id,
        },
        include: { role: { include: { permissions: true } } },
      });

      logger.info('New user synced from Clerk', {
        clerkId: auth.userId,
        userId: user.id,
      });
    }

    // Attach local user to request for downstream use
    req.localUser = user;
    next();
  } catch (error) {
    next(error);
  }
};
```

### 6.2 Webhook Sync (Real-Time)

For keeping user data in sync when changes happen on Clerk's side (email change, deletion, etc.):

```typescript
// src/modules/webhook/clerk-webhook.routes.ts
import { Router } from 'express';
import { Webhook } from 'svix';
import { config } from '@config/index.js';
import { prisma } from '@config/database.js';

export const clerkWebhookRouter = Router();

clerkWebhookRouter.post('/clerk', async (req, res) => {
  const payload = JSON.stringify(req.body);
  const headers = {
    'svix-id': req.headers['svix-id'] as string,
    'svix-timestamp': req.headers['svix-timestamp'] as string,
    'svix-signature': req.headers['svix-signature'] as string,
  };

  const wh = new Webhook(config.CLERK_WEBHOOK_SECRET);
  let event: { type: string; data: Record<string, unknown> };

  try {
    event = wh.verify(payload, headers) as typeof event;
  } catch {
    return res.status(400).json({ error: 'Invalid webhook signature' });
  }

  switch (event.type) {
    case 'user.created':
    case 'user.updated':
      await prisma.user.upsert({
        where: { clerkId: event.data.id as string },
        update: {
          email: (event.data.email_addresses as Array<{ email_address: string }>)?.[0]?.email_address,
          firstName: event.data.first_name as string,
          lastName: event.data.last_name as string,
        },
        create: {
          clerkId: event.data.id as string,
          email: (event.data.email_addresses as Array<{ email_address: string }>)?.[0]?.email_address ?? '',
          firstName: (event.data.first_name as string) ?? '',
          lastName: (event.data.last_name as string) ?? '',
          roleId: (await prisma.role.findUnique({ where: { name: 'Viewer' } }))!.id,
        },
      });
      break;

    case 'user.deleted':
      await prisma.user.update({
        where: { clerkId: event.data.id as string },
        data: { isActive: false },
      });
      break;
  }

  res.status(200).json({ received: true });
});
```

---

## 7. Clerk Session Token Customization

To include role/permission data in the JWT (so the auth guard can check permissions without a DB query), configure **custom claims** in Clerk Dashboard → Sessions → Customize session token:

```json
{
  "metadata": "{{user.public_metadata}}"
}
```

Then set public metadata on the Clerk user when assigning roles:

```typescript
// When assigning a role to a user
import { clerkClient } from '@clerk/express';

await clerkClient.users.updateUserMetadata(clerkUserId, {
  publicMetadata: {
    role: 'Admin',
    permissions: ['user:read', 'user:write', 'content:read'],
  },
});
```

This metadata is now available in `req.auth.sessionClaims.metadata`.

---

## 8. Express Type Augmentation

```typescript
// src/common/types/express.d.ts
import type { User, Role, Permission } from '@prisma/client';

type UserWithRole = User & {
  role: Role & { permissions: Permission[] };
};

declare global {
  namespace Express {
    interface Request {
      localUser?: UserWithRole;
      requestId?: string;
    }
  }
}
```

---

## 9. Auth Endpoints (Backend)

Most auth flows are handled by Clerk's frontend SDK. Our backend only exposes:

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/auth/me` | Clerk JWT | Get current user profile (local DB data + role) |
| `POST` | `/webhooks/clerk` | `@public` (Svix signature) | Clerk webhook receiver |

All other auth operations (signup, login, logout, password reset, MFA, OAuth) are handled **entirely by Clerk on the frontend**.

---

## 10. Security Rules

1. **Never** store passwords — Clerk handles all credential management.
2. **Never** implement custom login/signup endpoints — use Clerk's SDK.
3. **Never** trust `req.auth` without `clerkMiddleware()` having run first.
4. **Always** verify Clerk webhook signatures using `svix`.
5. **Always** sync user data to local DB for relational queries.
6. Clerk's `CLERK_SECRET_KEY` must **never** be exposed to the frontend.
7. `CLERK_PUBLISHABLE_KEY` is the **only** key safe for frontend use.
8. Set short session token lifetimes in Clerk Dashboard (recommended: 5 min).
9. Enable MFA in Clerk Dashboard for admin roles.
