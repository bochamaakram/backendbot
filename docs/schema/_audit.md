# 📝 Audit Trail System

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Purpose

Every **create**, **update**, and **delete** operation on a domain entity is automatically logged to the `AuditLog` table with before/after snapshots.

---

## 2. Database Model

```prisma
model AuditLog {
  id         String   @id @default(uuid())
  action     String   // "create" | "update" | "delete"
  resource   String   // e.g., "user", "product"
  resourceId String?
  actorId    String?
  actor      User?    @relation("AuditActor", fields: [actorId], references: [id], onDelete: SetNull)
  oldData    Json?    // Snapshot before change (null for create)
  newData    Json?    // Snapshot after change (null for delete)
  ip         String?
  userAgent  String?
  createdAt  DateTime @default(now())

  @@index([resource, resourceId])
  @@index([actorId])
  @@index([createdAt])
}
```

---

## 3. Audit Logger Utility

```typescript
// src/common/utils/audit.ts
import { prisma } from '@config/database.js';
import type { JwtPayload } from '@common/types/auth.types.js';

type AuditAction = 'create' | 'update' | 'delete';

export const auditLogger = {
  async log(
    action: AuditAction,
    resource: string,
    resourceId: string | null,
    actor: JwtPayload,
    oldData: Record<string, unknown> | null,
    newData: Record<string, unknown> | null,
  ): Promise<void> {
    await prisma.auditLog.create({
      data: {
        action,
        resource,
        resourceId,
        actorId: actor.sub,
        oldData: oldData ? sanitizeForAudit(oldData) : null,
        newData: newData ? sanitizeForAudit(newData) : null,
      },
    });
  },
};

/** Remove sensitive fields before storing in audit log */
function sanitizeForAudit(data: Record<string, unknown>): Record<string, unknown> {
  const SENSITIVE_FIELDS = ['password', 'token', 'refreshToken', 'secret'];
  const sanitized = { ...data };
  for (const field of SENSITIVE_FIELDS) {
    if (field in sanitized) {
      sanitized[field] = '[REDACTED]';
    }
  }
  return sanitized;
}
```

---

## 4. Usage (in Service Layer)

```typescript
// Called after every mutation in the service layer
await auditLogger.log('update', 'user', userId, req.localUser, oldUser, updatedUser);
```

---

## 5. Audit Query Endpoint

| Method | Path | Auth | Permission |
|--------|------|------|-----------|
| `GET` | `/audit-logs` | Bearer | `audit:read` |

Supports filtering by `resource`, `resourceId`, `actorId`, `action`, and date range.

---

## 6. Rules

1. Audit logging is done in the **service layer**, not controller or repository.
2. **Never** store raw passwords or tokens — sanitize before logging.
3. Audit logs are **append-only** — never update or delete them.
4. Audit log reads are restricted to `SuperAdmin` and `Admin` roles.
5. Old/new data snapshots capture the **full entity state** at the time of change.
