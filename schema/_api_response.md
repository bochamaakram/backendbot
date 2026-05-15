# 📦 API Response Envelope

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Response Contract

**Every** API response uses this envelope — no exceptions.

### Success Response

```json
{
  "success": true,
  "data": { },
  "meta": {
    "requestId": "uuid",
    "timestamp": "ISO-8601"
  }
}
```

### Success Response (with Pagination)

```json
{
  "success": true,
  "data": [ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "ISO-8601"
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": null
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "ISO-8601"
  }
}
```

---

## 2. Response Helper

```typescript
// src/common/utils/api-response.ts
import { Response, Request } from 'express';

interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
}

export class ApiResponse {
  static success<T>(res: Response, req: Request, data: T, statusCode = 200): void {
    res.status(statusCode).json({
      success: true,
      data,
      meta: {
        requestId: req.requestId,
        timestamp: new Date().toISOString(),
      },
    });
  }

  static paginated<T>(
    res: Response,
    req: Request,
    data: T[],
    pagination: PaginationMeta,
  ): void {
    const totalPages = Math.ceil(pagination.total / pagination.limit);

    res.status(200).json({
      success: true,
      data,
      pagination: {
        page: pagination.page,
        limit: pagination.limit,
        total: pagination.total,
        totalPages,
        hasNext: pagination.page < totalPages,
        hasPrev: pagination.page > 1,
      },
      meta: {
        requestId: req.requestId,
        timestamp: new Date().toISOString(),
      },
    });
  }

  static created<T>(res: Response, req: Request, data: T): void {
    ApiResponse.success(res, req, data, 201);
  }

  static noContent(res: Response): void {
    res.status(204).send();
  }
}
```

### Usage in Controller

```typescript
class UserController {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await userService.create(req.body);
      ApiResponse.created(res, req, user);
    } catch (error) {
      next(error);
    }
  }

  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const { data, total } = await userService.findAll(req.query);
      ApiResponse.paginated(res, req, data, {
        page: req.query.page,
        limit: req.query.limit,
        total,
      });
    } catch (error) {
      next(error);
    }
  }
}
```

---

## 3. HTTP Status Code Usage

| Status | When |
|--------|------|
| `200` | Successful GET, PUT, PATCH |
| `201` | Successful POST (resource created) |
| `204` | Successful DELETE (no content) |
| `400` | Validation error |
| `401` | Missing/invalid auth token |
| `403` | Authenticated but lacks permission |
| `404` | Resource not found |
| `409` | Conflict (duplicate) |
| `429` | Rate limit exceeded |
| `500` | Unexpected server error |

---

## 4. Rules

1. **Every** response must go through `ApiResponse` helpers — no raw `res.json()`.
2. **Never** return data without wrapping in the envelope.
3. Error responses are handled by the error middleware (not `ApiResponse`).
4. `requestId` and `timestamp` are always present in `meta`.
5. Paginated responses always include full pagination metadata.
