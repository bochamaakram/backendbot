# 🛡️ Authorization (RBAC)

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Model

**Role-Based Access Control (RBAC)** with Clerk + local database.

- Clerk handles **authentication** (identity verification).
- Our local DB handles **authorization** (roles & permissions).
- A **User** (synced from Clerk) has exactly one **Role** in our DB.
- A **Role** has many **Permissions**.
- Permissions follow the `resource:action` pattern.
- Optionally, roles are also stored in Clerk's `publicMetadata` for JWT-level access.

---

## 2. Database Models

```prisma
enum RoleType {
  SuperAdmin
  Admin
  Manager
  Editor
  Viewer
}

model Role {
  id          String       @id @default(uuid())
  name        RoleType     @unique
  description String?
  permissions Permission[]
  users       User[]
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt
}

model Permission {
  id       String @id @default(uuid())
  resource String // e.g., "user", "role", "product"
  action   String // e.g., "create", "read", "update", "delete"
  roles    Role[]

  @@unique([resource, action])
}
```

---

## 3. Permission Matrix

| Permission | SuperAdmin | Admin | Manager | Editor | Viewer |
|------------|:---:|:---:|:---:|:---:|:---:|
| `user:create` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `user:read` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `user:update` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `user:delete` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `role:create` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `role:read` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `role:update` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `role:delete` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `content:create` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `content:read` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `content:update` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `content:delete` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `audit:read` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `settings:read` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `settings:update` | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## 4. Permission Guard

```typescript
// src/common/guards/permission.guard.ts
import { Request, Response, NextFunction } from 'express';
import { ForbiddenError, UnauthorizedError } from '@common/errors/index.js';

type PermissionString = `${string}:${string}`;

/**
 * Permission guard that checks against the local user's role permissions.
 * Requires `syncUserMiddleware` to have run first (populates `req.localUser`).
 */
export const requirePermission = (...required: PermissionString[]) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.localUser) {
      throw new UnauthorizedError('Authentication required');
    }

    // SuperAdmin bypasses all permission checks
    if (req.localUser.role.name === 'SuperAdmin') {
      next();
      return;
    }

    const userPermissions = req.localUser.role.permissions.map(
      (p) => `${p.resource}:${p.action}`,
    );
    const hasAll = required.every((p) => userPermissions.includes(p));

    if (!hasAll) {
      throw new ForbiddenError(
        `Missing required permissions: ${required.join(', ')}`,
      );
    }

    next();
  };
};
```

### Usage

```typescript
router.delete(
  '/:id',
  authGuard,              // 1. Clerk JWT verification
  syncUserMiddleware,     // 2. Sync Clerk user → local DB (populates req.localUser)
  requirePermission('user:delete'),  // 3. Check local permissions
  userController.delete,
);
```

---

## 5. Role Hierarchy

`SuperAdmin` > `Admin` > `Manager` > `Editor` > `Viewer`

- Higher roles **inherit** all permissions of lower roles.
- `SuperAdmin` bypasses all permission checks (guard shortcut).

---

## 6. Rules

1. **Never** hardcode role names in business logic — check permissions instead.
2. Permission checks happen **after** Clerk authentication (auth guard first, then sync, then permission guard).
3. `SuperAdmin` is a bypass role — only 1 should exist per system.
4. New modules **must** add their permissions to this matrix and seed them.
5. Role assignment is restricted to `user:update` + `role:read` permissions.
6. When assigning a role, also update Clerk's `publicMetadata` via `clerkClient.users.updateUserMetadata()` for JWT-level visibility.
