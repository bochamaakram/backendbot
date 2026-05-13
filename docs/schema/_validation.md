# ✅ Request Validation

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Library | Zod 3.x |
| Validation target | `body`, `query`, `params` (independently) |
| Location | Middleware layer (before controller) |
| Error output | Standardized `ValidationError` with field-level details |

---

## 2. Validation Middleware

```typescript
// src/common/middleware/validate.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { ValidationError } from '@common/errors/index.js';

interface ValidationSchemas {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export const validate = (schemas: ValidationSchemas) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    const errors: Record<string, string[]> = {};

    for (const [key, schema] of Object.entries(schemas)) {
      if (!schema) continue;

      const target = key as keyof ValidationSchemas;
      const result = schema.safeParse(req[target]);

      if (!result.success) {
        errors[target] = result.error.issues.map(
          (issue) => `${issue.path.join('.')}: ${issue.message}`,
        );
      } else {
        // Replace req data with parsed (coerced/transformed) values
        (req as Record<string, unknown>)[target] = result.data;
      }
    }

    if (Object.keys(errors).length > 0) {
      throw new ValidationError('Validation failed', { errors });
    }

    next();
  };
};
```

---

## 3. Schema File Pattern

Each module has a `*.validator.ts` file:

```typescript
// src/modules/user/user.validator.ts
import { z } from 'zod';

export const createUserSchema = {
  body: z.object({
    email: z.string().email('Invalid email format'),
    password: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .max(128)
      .regex(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/,
        'Password must contain uppercase, lowercase, digit, and special char',
      ),
    firstName: z.string().min(1).max(100).trim(),
    lastName: z.string().min(1).max(100).trim(),
    roleId: z.string().uuid('Invalid role ID'),
  }),
};

export const updateUserSchema = {
  params: z.object({
    id: z.string().uuid('Invalid user ID'),
  }),
  body: z.object({
    email: z.string().email().optional(),
    firstName: z.string().min(1).max(100).trim().optional(),
    lastName: z.string().min(1).max(100).trim().optional(),
    isActive: z.boolean().optional(),
    roleId: z.string().uuid().optional(),
  }),
};

export const getUserSchema = {
  params: z.object({
    id: z.string().uuid('Invalid user ID'),
  }),
};

export const listUsersSchema = {
  query: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
    sortBy: z.enum(['createdAt', 'email', 'firstName']).default('createdAt'),
    sortOrder: z.enum(['asc', 'desc']).default('desc'),
    search: z.string().optional(),
    isActive: z.coerce.boolean().optional(),
    roleId: z.string().uuid().optional(),
  }),
};
```

### Usage in Routes

```typescript
router.post('/', authGuard, requirePermission('user:create'), validate(createUserSchema), userController.create);
router.get('/', authGuard, requirePermission('user:read'), validate(listUsersSchema), userController.list);
router.get('/:id', authGuard, requirePermission('user:read'), validate(getUserSchema), userController.findById);
router.patch('/:id', authGuard, requirePermission('user:update'), validate(updateUserSchema), userController.update);
```

---

## 4. Common Reusable Schemas

```typescript
// src/common/validators/common.validators.ts
import { z } from 'zod';

export const uuidParam = z.object({
  id: z.string().uuid(),
});

export const paginationQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.string().default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export const searchQuery = paginationQuery.extend({
  search: z.string().max(200).optional(),
});
```

---

## 5. Error Response Format

When validation fails, the response follows the standard error envelope:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "errors": {
        "body": [
          "email: Invalid email format",
          "password: Password must be at least 8 characters"
        ]
      }
    }
  },
  "meta": {
    "requestId": "abc-123",
    "timestamp": "2026-05-13T10:00:00.000Z"
  }
}
```

---

## 6. Rules

1. **Every** route with body/query/params **must** have validation.
2. Validation runs **after** auth — never validate input for unauthenticated requests.
3. Use `.trim()` on all string inputs to prevent whitespace issues.
4. Use `z.coerce` for query params (they arrive as strings).
5. Re-assign parsed values to `req` — this gives you type-safe, sanitized data.
6. **Never** validate inside the controller or service — only in middleware.
