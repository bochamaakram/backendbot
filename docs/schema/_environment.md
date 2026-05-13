# 🔐 Environment Variables & Configuration

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Configuration Strategy

- All config is loaded from environment variables via `dotenv` (dev) or OS-level injection (prod).
- **Every** variable is validated at startup using Zod — the app **crashes immediately** if validation fails.
- A single `config` object is exported from `src/config/index.ts`.
- **Never** access `process.env` directly outside `src/config/index.ts`.

---

## 2. Variable Registry

### 2.1 Application

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `NODE_ENV` | `string` | ✅ | `development` | `development` \| `staging` \| `production` \| `test` |
| `PORT` | `number` | ❌ | `3000` | HTTP server port |
| `API_PREFIX` | `string` | ❌ | `/api/v1` | Global route prefix |
| `APP_NAME` | `string` | ❌ | `BackOffice` | Application name for logs |
| `APP_URL` | `string` | ✅ | — | Full base URL (e.g., `https://api.example.com`) |

### 2.2 Database

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `DATABASE_URL` | `string` | ✅ | — | PostgreSQL connection string |
| `DATABASE_POOL_MIN` | `number` | ❌ | `2` | Minimum pool connections |
| `DATABASE_POOL_MAX` | `number` | ❌ | `10` | Maximum pool connections |

### 2.3 Authentication (Clerk)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `CLERK_PUBLISHABLE_KEY` | `string` | ✅ | — | Clerk publishable key (safe for frontend) |
| `CLERK_SECRET_KEY` | `string` | ✅ | — | Clerk secret key (backend only) |
| `CLERK_WEBHOOK_SECRET` | `string` | ✅ | — | Svix webhook signing secret from Clerk |

### 2.4 CORS

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `CORS_ORIGINS` | `string` | ❌ | `*` | Comma-separated allowed origins |
| `CORS_CREDENTIALS` | `boolean` | ❌ | `true` | Allow credentials |

### 2.5 Rate Limiting

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `RATE_LIMIT_WINDOW_MS` | `number` | ❌ | `900000` | Window in ms (15 min) |
| `RATE_LIMIT_MAX` | `number` | ❌ | `100` | Max requests per window |

### 2.6 Logging

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `LOG_LEVEL` | `string` | ❌ | `info` | `debug` \| `info` \| `warn` \| `error` |
| `LOG_FORMAT` | `string` | ❌ | `json` | `json` \| `pretty` |

### 2.7 File Upload

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `UPLOAD_MAX_SIZE_MB` | `number` | ❌ | `10` | Max file size in MB |
| `UPLOAD_DEST` | `string` | ❌ | `./uploads` | Upload destination path |
| `UPLOAD_ALLOWED_TYPES` | `string` | ❌ | `image/*,application/pdf` | Comma-separated MIME types |

---

## 3. Validation Schema

```typescript
// src/config/index.ts
import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  API_PREFIX: z.string().default('/api/v1'),
  APP_NAME: z.string().default('BackOffice'),
  APP_URL: z.string().url(),

  DATABASE_URL: z.string().min(1),
  DATABASE_POOL_MIN: z.coerce.number().default(2),
  DATABASE_POOL_MAX: z.coerce.number().default(10),

  CLERK_PUBLISHABLE_KEY: z.string().startsWith('pk_'),
  CLERK_SECRET_KEY: z.string().startsWith('sk_'),
  CLERK_WEBHOOK_SECRET: z.string().min(1),

  CORS_ORIGINS: z.string().default('*'),
  CORS_CREDENTIALS: z
    .string()
    .transform((v) => v === 'true')
    .default('true'),

  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(900_000),
  RATE_LIMIT_MAX: z.coerce.number().default(100),

  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  LOG_FORMAT: z.enum(['json', 'pretty']).default('json'),

  UPLOAD_MAX_SIZE_MB: z.coerce.number().default(10),
  UPLOAD_DEST: z.string().default('./uploads'),
  UPLOAD_ALLOWED_TYPES: z.string().default('image/*,application/pdf'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const config = parsed.data;
export type Config = z.infer<typeof envSchema>;
```

---

## 4. `.env.example`

```bash
# Application
NODE_ENV=development
PORT=3000
API_PREFIX=/api/v1
APP_NAME=BackOffice
APP_URL=http://localhost:3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/backoffice?schema=public

# Authentication (Clerk)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx
CLERK_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxx

# CORS
CORS_ORIGINS=http://localhost:5173,http://localhost:3001
CORS_CREDENTIALS=true

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100

# Logging
LOG_LEVEL=debug
LOG_FORMAT=pretty

# File Upload
UPLOAD_MAX_SIZE_MB=10
UPLOAD_DEST=./uploads
UPLOAD_ALLOWED_TYPES=image/*,application/pdf
```

---

## 5. Rules

1. **Never** commit `.env` — only `.env.example`.
2. **Never** access `process.env` outside `src/config/index.ts`.
3. **Always** add new variables to this doc, the Zod schema, AND `.env.example`.
4. Clerk keys are obtained from the Clerk Dashboard — never generate them manually.
5. The app **must crash** on invalid config — no silent fallbacks for required vars.
