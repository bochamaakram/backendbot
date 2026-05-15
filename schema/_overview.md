# 📐 Back Office — Architecture Overview

> **Status:** Source of Truth  
> **Stack:** Express.js (TypeScript) · Prisma · PostgreSQL · Clerk Auth  
> **Last Updated:** 2026-05-13

---

## 1. Purpose

This directory (`/schema/`) is the **single, authoritative blueprint** for every layer of the Back Office API. Any code-generation agent, developer, or CI pipeline **MUST** treat these files as immutable specifications unless a human maintainer explicitly revises them.

---

## 2. Design Principles

| # | Principle | Rationale |
|---|-----------|-----------|
| 1 | **Schema-First** | Database models, DTOs, and validations are derived from these docs — never ad-hoc. |
| 2 | **Separation of Concerns** | Routes → Controllers → Services → Repositories → Prisma. No layer may skip another. |
| 3 | **Fail-Safe Defaults** | Every endpoint is authenticated & authorized unless explicitly marked `@public`. |
| 4 | **Idempotent Mutations** | PUT/PATCH operations produce the same result regardless of how many times they run. |
| 5 | **Auditable** | Every write operation produces an audit-trail entry automatically. |
| 6 | **Zero-Trust Validation** | Input is validated at the edge (middleware) and again at the service layer. |

---

## 3. Schema File Index

| File | Domain | Description |
|------|--------|-------------|
| [`_overview.md`](./_overview.md) | Meta | This file — architecture overview & file index |
| [`_filestructure.md`](./_filestructure.md) | Meta | Standardized high-level project file structure |
| [`_conventions.md`](./_conventions.md) | Meta | Naming, coding style, folder layout conventions |
| [`_environment.md`](./_environment.md) | Config | Environment variables & configuration management |
| [`_authentication.md`](./_authentication.md) | Auth | Clerk integration, user sync, webhook handling |
| [`_authorization.md`](./_authorization.md) | Auth | RBAC model, permission matrix, guard implementation |
| [`_middleware.md`](./_middleware.md) | Core | Global & route-level middleware stack |
| [`_error_handling.md`](./_error_handling.md) | Core | Error taxonomy, error response contract |
| [`_database.md`](./_database.md) | Data | Prisma schema, migration strategy, seeding |
| [`_validation.md`](./_validation.md) | Core | Request validation with Zod schemas |
| [`_api_response.md`](./_api_response.md) | Core | Standardized API response envelope |
| [`_logging.md`](./_logging.md) | Ops | Structured logging & request tracing |
| [`_testing.md`](./_testing.md) | QA | Testing strategy, fixtures, coverage targets |
| [`_deployment.md`](./_deployment.md) | Ops | Docker, CI/CD pipeline, health checks |
| [`_modules.md`](./_modules.md) | Feature | Module generation pattern & CRUD scaffold |
| [`_audit.md`](./_audit.md) | Core | Audit trail system & change-tracking |
| [`_pagination.md`](./_pagination.md) | Core | Cursor & offset pagination contract |
| [`_file_upload.md`](./_file_upload.md) | Feature | File upload handling & storage strategy |
| [`_rate_limiting.md`](./_rate_limiting.md) | Security | Rate limiting & throttling strategy |
| [`_security.md`](./_security.md) | Security | Security headers, CORS, CSRF, input sanitization |

---

## 4. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│              CLIENT (SPA / Mobile)                       │
│           Uses Clerk SDK for auth UI                     │
└──────────────────────┬──────────────────────────────────┘
                       │  HTTPS (Authorization: Bearer <clerk-jwt>)
┌──────────────────────▼──────────────────────────────────┐
│                   NGINX / Load Balancer                 │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                   Express.js Application                │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Global Middleware Stack                          │  │
│  │  ┌─────────┐ ┌────────┐ ┌──────┐ ┌───────────┐  │  │
│  │  │ Helmet  │ │ CORS   │ │Clerk │ │ Request   │  │  │
│  │  │         │ │        │ │ MW   │ │ Logger    │  │  │
│  │  └─────────┘ └────────┘ └──────┘ └───────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Router Layer                                     │  │
│  │  /api/v1/users      → UserController              │  │
│  │  /api/v1/roles      → RoleController              │  │
│  │  /api/v1/…          → ModuleController             │  │
│  │  /webhooks/clerk    → ClerkWebhookHandler          │  │
│  └──────────────────────┬────────────────────────────┘  │
│  ┌──────────────────────▼────────────────────────────┐  │
│  │  Controller Layer (thin — delegates to service)   │  │
│  └──────────────────────┬────────────────────────────┘  │
│  ┌──────────────────────▼────────────────────────────┐  │
│  │  Service Layer (business logic, validation)       │  │
│  └──────────────────────┬────────────────────────────┘  │
│  ┌──────────────────────▼────────────────────────────┐  │
│  │  Repository Layer (data access, Prisma calls)     │  │
│  └──────────────────────┬────────────────────────────┘  │
│  ┌──────────────────────▼────────────────────────────┐  │
│  │  Prisma ORM → PostgreSQL                          │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 5. Request Lifecycle

```
Request
  │
  ├─ 1. Global Middleware (helmet, cors, body-parser, request-id)
  ├─ 2. Clerk Middleware (parses & verifies JWT from Authorization header)
  ├─ 3. Rate Limiter
  ├─ 4. Request Logger (correlation ID injected)
  ├─ 5. Route Matching
  ├─ 6. Auth Guard (requireAuth — rejects unauthenticated)
  ├─ 7. User Sync Middleware (Clerk user → local DB)
  ├─ 8. Permission Guard (RBAC check against local DB)
  ├─ 9. Validation Middleware (Zod schema)
  ├─ 10. Controller (extract params → call service)
  ├─ 11. Service (business rules → call repository)
  ├─ 12. Repository (Prisma query)
  ├─ 13. Audit Logger (writes change record)
  ├─ 14. Response Serializer (envelope wrapper)
  │
  └─▶ Response
```

---

## 6. Agent Instructions

> **IMPORTANT — Read Before Generating Code**

1. **Always read the relevant schema file** before writing or modifying any code in the corresponding domain.
2. **Never deviate** from the patterns specified here unless the user explicitly overrides them.
3. When creating a new module, follow the exact scaffold defined in [`_modules.md`](./_modules.md).
4. When adding middleware, register it in the order defined in [`_middleware.md`](./_middleware.md).
5. All error responses **must** use the envelope defined in [`_api_response.md`](./_api_response.md).
6. All database changes **must** be expressed as Prisma migrations — never raw SQL in application code.
7. Environment variables **must** be declared in [`_environment.md`](./_environment.md) before use.
8. Every route **must** have validation, auth, and permission guards unless explicitly annotated `@public`.
9. **Authentication is handled by Clerk** — never implement custom login/signup/password endpoints.
10. All protected routes must use `authGuard` (Clerk's `requireAuth()`) + `syncUserMiddleware` + `requirePermission()`.
11. **Post-Task Completion**: After finishing the requested task, the agent MUST create a Docker image of the application to ensure it is ready for deployment.

---

## 7. Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-05-13 | Architect | Initial schema creation |
| 1.1.0 | 2026-05-13 | Architect | Migrated auth from in-house JWT to Clerk |
| 1.2.0 | 2026-05-15 | Architect | Added mandatory Docker image creation after task completion |
| 1.3.0 | 2026-05-15 | Architect | Added _filestructure.md and updated directory references |
