# 📏 Conventions & Coding Standards

> **Status:** Source of Truth  
> **Applies to:** All application code  
> **Last Updated:** 2026-05-13

---

## 1. Language & Runtime

| Item | Standard |
|------|----------|
| Language | TypeScript 5.x (strict mode) |
| Runtime | Node.js ≥ 20 LTS |
| Module System | ES Modules (`"type": "module"`) |
| Build Tool | `tsx` for dev, `tsc` for production |

---

## 2. Naming Conventions

### Files & Directories

| Element | Convention | Example |
|---------|-----------|---------|
| Module dir | `kebab-case` (singular) | `src/modules/user/` |
| Source file | `kebab-case.purpose.ts` | `user.controller.ts` |
| Test file | `kebab-case.purpose.test.ts` | `user.service.test.ts` |

### Code Identifiers

| Element | Convention | Example |
|---------|-----------|---------|
| Class | `PascalCase` | `UserService` |
| Interface | `PascalCase` (no `I` prefix) | `UserCreateInput` |
| Function | `camelCase` | `findUserById` |
| Constant | `SCREAMING_SNAKE_CASE` | `MAX_LOGIN_ATTEMPTS` |
| Enum | `PascalCase` | `Role.SuperAdmin` |
| DB model (Prisma) | `PascalCase` singular | `model User {}` |
| Route path | `kebab-case` plural | `/api/v1/user-roles` |
| Env variable | `SCREAMING_SNAKE_CASE` | `DATABASE_URL` |

---

## 3. Import Order

```typescript
// 1. Node.js built-ins
import { randomUUID } from 'node:crypto';

// 2. Third-party packages
import { Router } from 'express';
import { z } from 'zod';

// 3. Internal aliases (@config, @common, @modules)
import { config } from '@config/index.js';
import { AppError } from '@common/errors/app-error.js';

// 4. Relative imports
import { UserService } from './user.service.js';
import type { CreateUserDto } from './user.types.js';
```

---

## 4. Export Rules

- **Named exports only** — no default exports (except `app` from `app.ts`).
- Group type exports: `export type { ... }`.
- Barrel files (`index.ts`) only in `common/`.

---

## 5. Function Rules

- Max length: **40 lines** (excluding JSDoc).
- Max params: **3** — use options object beyond that.
- Every public function: JSDoc with `@param`, `@returns`, `@throws`.
- Prefer `async/await` — never raw `.then()` chains.
- Never use `any` — use `unknown` + type guards.

---

## 6. Layer Responsibilities

```
Layer         │ Allowed Dependencies          │ Forbidden
──────────────┼───────────────────────────────┼──────────────────
Routes        │ Controller, Middleware, Guard  │ Service, Repository
Controller    │ Service, Validator types       │ Repository, Prisma
Service       │ Repository, other Services     │ Prisma direct, req/res
Repository    │ Prisma Client                  │ Express, business logic
```

---

## 7. Error Handling

- **Always** throw `AppError` or subclasses — never raw strings.
- **Never** catch silently — log and re-throw or handle.
- Follow taxonomy in `_error_handling.md`.

---

## 8. Git Conventions

### Commits (Conventional Commits)

```
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

### Branches

```
<type>/<ticket-id>-<short-description>
```

---

## 9. Approved Dependencies

| Package | Purpose |
|---------|---------|
| `express` | HTTP framework |
| `@prisma/client` | ORM |
| `zod` | Validation |
| `@clerk/express` | Authentication (Clerk SDK) |
| `svix` | Clerk webhook verification |
| `helmet` | Security headers |
| `cors` | CORS |
| `winston` / `pino` | Logging |
| `express-rate-limit` | Rate limiting |
| `multer` | File uploads |
| `dotenv` | Env loading (dev) |

### Forbidden

- ❌ `class-validator` / `class-transformer` — use Zod
- ❌ `mongoose` — Prisma only
- ❌ `lodash` — native ES2022+
- ❌ `moment` — native Date
- ❌ Wildcard imports

---

## 10. Code Quality

| Tool | Config |
|------|--------|
| ESLint | `.eslintrc.cjs` |
| Prettier | `.prettierrc` |
| Husky | `.husky/` |

### Prettier

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

---

## 11. TypeScript Config

```jsonc
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": "./src",
    "paths": {
      "@config/*": ["config/*"],
      "@common/*": ["common/*"],
      "@modules/*": ["modules/*"]
    },
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```
