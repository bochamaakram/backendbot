# 🧪 Testing Strategy

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Testing Stack

| Tool | Purpose |
|------|---------|
| Vitest | Test runner & assertions |
| Supertest | HTTP integration testing |
| Prisma (`@prisma/client`) | Test database via migrations |
| Factory functions | Test data generation |

---

## 2. Test Types & Coverage

| Type | Location | Target | Min Coverage |
|------|----------|--------|-------------|
| **Unit** | `src/modules/<mod>/__tests__/*.test.ts` | Services, utils | 80% |
| **Integration** | `src/__tests__/integration/` | Controller + DB | 70% |
| **E2E** | `src/__tests__/e2e/` | Full request lifecycle | Key flows |

---

## 3. Test File Structure

```
src/modules/user/__tests__/
├── user.service.test.ts      # Unit tests for UserService
├── user.controller.test.ts   # Integration tests for routes
└── user.factory.ts           # Test data factories
```

---

## 4. Factory Pattern

```typescript
// src/modules/user/__tests__/user.factory.ts
import { faker } from '@faker-js/faker';
import type { Prisma } from '@prisma/client';

export const createUserData = (
  overrides?: Partial<Prisma.UserCreateInput>,
): Prisma.UserCreateInput => ({
  email: faker.internet.email(),
  password: 'Test@1234',
  firstName: faker.person.firstName(),
  lastName: faker.person.lastName(),
  role: { connect: { name: 'Viewer' } },
  ...overrides,
});
```

---

## 5. Test Database

- Use a **separate** PostgreSQL database for tests (e.g., `backoffice_test`).
- Configured via `DATABASE_URL` in `.env.test`.
- Migrations applied before test suite runs.
- Database **reset** between test suites (not individual tests).

---

## 6. Commands

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific module
npm test -- --filter user

# Run in watch mode
npm run test:watch
```

---

## 7. Rules

1. **Never** test against the development database.
2. Each test must be independent — no shared mutable state.
3. Mock external services (email, storage) — never call real APIs in tests.
4. Use factories for test data — never hardcode fixtures inline.
5. Test the **contract** (input → output), not implementation details.
6. Every new module must include tests before merge.
