# ❌ Error Handling

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Error Class Hierarchy

```
AppError (abstract base)
├── ValidationError     (400)
├── UnauthorizedError   (401)
├── ForbiddenError      (403)
├── NotFoundError       (404)
├── ConflictError       (409)
├── RateLimitError      (429)
└── InternalError       (500)
```

---

## 2. Base Error Class

```typescript
// src/common/errors/app-error.ts
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly code: string;
  readonly isOperational: boolean;

  constructor(
    message: string,
    public readonly details?: Record<string, unknown>,
    isOperational = true,
  ) {
    super(message);
    this.name = this.constructor.name;
    this.isOperational = isOperational;
    Error.captureStackTrace(this, this.constructor);
  }
}
```

---

## 3. Error Subclasses

```typescript
// src/common/errors/http-errors.ts
import { AppError } from './app-error.js';

export class ValidationError extends AppError {
  readonly statusCode = 400;
  readonly code = 'VALIDATION_ERROR';
}

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
  readonly code = 'UNAUTHORIZED';
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;
  readonly code = 'FORBIDDEN';
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly code = 'NOT_FOUND';
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
  readonly code = 'CONFLICT';
}

export class RateLimitError extends AppError {
  readonly statusCode = 429;
  readonly code = 'RATE_LIMIT_EXCEEDED';
}

export class InternalError extends AppError {
  readonly statusCode = 500;
  readonly code = 'INTERNAL_ERROR';

  constructor(message = 'An unexpected error occurred', details?: Record<string, unknown>) {
    super(message, details, false); // Not operational
  }
}
```

---

## 4. Global Error Middleware

```typescript
// src/common/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from '@common/errors/app-error.js';
import { logger } from '@config/logger.js';
import { config } from '@config/index.js';

export const errorMiddleware = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  if (err instanceof AppError) {
    logger.warn('Operational error', {
      requestId: req.requestId,
      code: err.code,
      message: err.message,
      statusCode: err.statusCode,
    });

    res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details ?? null,
      },
      meta: {
        requestId: req.requestId,
        timestamp: new Date().toISOString(),
      },
    });
    return;
  }

  // Unexpected errors
  logger.error('Unexpected error', {
    requestId: req.requestId,
    error: err.message,
    stack: err.stack,
  });

  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: config.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : err.message,
      details: null,
    },
    meta: {
      requestId: req.requestId,
      timestamp: new Date().toISOString(),
    },
  });
};
```

---

## 5. Prisma Error Mapping

```typescript
// src/common/errors/prisma-error.mapper.ts
import { Prisma } from '@prisma/client';
import { ConflictError, NotFoundError, ValidationError } from './http-errors.js';

export const mapPrismaError = (error: Prisma.PrismaClientKnownRequestError): AppError => {
  switch (error.code) {
    case 'P2002':
      return new ConflictError('Resource already exists', {
        fields: error.meta?.target,
      });
    case 'P2025':
      return new NotFoundError('Resource not found');
    case 'P2003':
      return new ValidationError('Invalid reference', {
        field: error.meta?.field_name,
      });
    default:
      return new InternalError('Database error');
  }
};
```

---

## 6. Rules

1. **Always** throw `AppError` subclasses — never raw `Error` or strings.
2. **Never** expose stack traces in production.
3. **Never** expose internal details (DB column names, file paths) in error responses.
4. Prisma errors **must** be caught in the repository layer and mapped via `mapPrismaError`.
5. Operational errors (4xx) are logged as `warn`; unexpected errors (5xx) as `error`.
6. Every error response **must** include `requestId` and `timestamp`.
