# 🗄️ Database & Prisma

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Database

| Item | Value |
|------|-------|
| Engine | PostgreSQL 16+ |
| Hosting | **Supabase** (Mandatory) |
| ORM | Prisma 6.x |
| Schema file | `prisma/schema.prisma` |
| Migrations | `prisma/migrations/` (auto-generated) |
| Seed file | `prisma/seed.ts` |

---

## 2. Prisma Client Singleton

```typescript
// src/config/database.ts
import { PrismaClient } from '@prisma/client';
import { config } from '@config/index.js';
import { logger } from '@config/logger.js';

const createPrismaClient = (): PrismaClient => {
  const client = new PrismaClient({
    log:
      config.NODE_ENV === 'development'
        ? [
            { level: 'query', emit: 'event' },
            { level: 'warn', emit: 'stdout' },
            { level: 'error', emit: 'stdout' },
          ]
        : [{ level: 'error', emit: 'stdout' }],
  });

  if (config.NODE_ENV === 'development') {
    client.$on('query' as never, (e: { query: string; duration: number }) => {
      logger.debug('Prisma query', { query: e.query, duration: `${e.duration}ms` });
    });
  }

  return client;
};

// Singleton — reuse across the application
export const prisma = createPrismaClient();

// Graceful shutdown
export const disconnectDatabase = async (): Promise<void> => {
  await prisma.$disconnect();
  logger.info('Database disconnected');
};
```

---

## 3. Base Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─── Core Models ─────────────────────────────

model User {
  id            String         @id @default(uuid())
  clerkId       String         @unique   // Clerk user ID (e.g., "user_2abc123...")
  email         String         @unique
  firstName     String
  lastName      String
  isActive      Boolean        @default(true)
  lastLoginAt   DateTime?
  roleId        String
  role          Role           @relation(fields: [roleId], references: [id])
  auditLogs     AuditLog[]     @relation("AuditActor")
  createdAt     DateTime       @default(now())
  updatedAt     DateTime       @updatedAt

  @@index([clerkId])
  @@index([email])
  @@index([roleId])
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
  resource String
  action   String
  roles    Role[]

  @@unique([resource, action])
}

model AuditLog {
  id         String   @id @default(uuid())
  action     String
  resource   String
  resourceId String?
  actorId    String?
  actor      User?    @relation("AuditActor", fields: [actorId], references: [id], onDelete: SetNull)
  oldData    Json?
  newData    Json?
  ip         String?
  userAgent  String?
  createdAt  DateTime @default(now())

  @@index([resource, resourceId])
  @@index([actorId])
  @@index([createdAt])
}

// ─── Enums ───────────────────────────────────

enum RoleType {
  SuperAdmin
  Admin
  Manager
  Editor
  Viewer
}
```

---

## 4. Model Conventions

| Convention | Rule |
|-----------|------|
| Primary Key | `id String @id @default(uuid())` |
| Timestamps | Always include `createdAt` + `updatedAt` |
| Soft delete | Use `isActive Boolean @default(true)` — never hard-delete users |
| Relations | Always name with `@relation` |
| Indexes | Add for any column used in `WHERE`, `ORDER BY`, or `JOIN` |
| Enums | Define in Prisma schema, not application code |

---

## 5. Migration Commands

```bash
# Create migration from schema changes
npx prisma migrate dev --name <description>

# Apply migrations in production
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset

# Generate Prisma Client
npx prisma generate

# Open Prisma Studio
npx prisma studio
```

---

## 6. Seed Script

```typescript
// prisma/seed.ts
import { PrismaClient, RoleType } from '@prisma/client';

const prisma = new PrismaClient();

const PERMISSIONS = [
  { resource: 'user', actions: ['create', 'read', 'update', 'delete'] },
  { resource: 'role', actions: ['create', 'read', 'update', 'delete'] },
  { resource: 'content', actions: ['create', 'read', 'update', 'delete'] },
  { resource: 'audit', actions: ['read'] },
  { resource: 'settings', actions: ['read', 'update'] },
];

async function main() {
  // Create permissions
  for (const perm of PERMISSIONS) {
    for (const action of perm.actions) {
      await prisma.permission.upsert({
        where: { resource_action: { resource: perm.resource, action } },
        update: {},
        create: { resource: perm.resource, action },
      });
    }
  }

  // Create roles with permissions (see _authorization.md matrix)
  // ... role creation with permission assignments

  // NOTE: SuperAdmin user is NOT created in seed.
  // Create a user via Clerk, then assign SuperAdmin role
  // by updating their local DB record and Clerk publicMetadata.
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

---

## 7. Rules

1. **Always** host the database on **Supabase** (PostgreSQL). No other database hosting providers are permitted for this factory blueprint.
2. **Never** use raw SQL in application code — always use Prisma Client.
3. **Never** import `PrismaClient` directly — use the singleton from `@config/database.js`.
4. **Always** create migrations for schema changes — never modify the DB manually.
5. **Always** add indexes for frequently queried columns.
6. Use `uuid` for all primary keys — never auto-increment integers.
7. Soft-delete for user-facing entities; hard-delete only for technical records.
8. The `User.clerkId` field is the bridge between Clerk identity and local DB records.
9. **Never** store passwords — Clerk handles all credential management.
