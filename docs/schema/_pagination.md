# 📄 Pagination

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Default method | **Offset-based** (page + limit) |
| Optional | Cursor-based for real-time feeds |
| Max page size | `100` items |
| Default page size | `20` items |

---

## 2. Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | `number` | `1` | Current page (1-indexed) |
| `limit` | `number` | `20` | Items per page (max 100) |
| `sortBy` | `string` | `createdAt` | Column to sort by |
| `sortOrder` | `asc` \| `desc` | `desc` | Sort direction |
| `search` | `string` | — | Full-text search (optional) |

---

## 3. Response Format

```json
{
  "success": true,
  "data": [],
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

---

## 4. Repository Pattern

```typescript
async findAll(query: PaginatedQuery) {
  const { page, limit, sortBy, sortOrder, search } = query;
  const skip = (page - 1) * limit;

  const where = search
    ? { name: { contains: search, mode: 'insensitive' as const } }
    : {};

  const [data, total] = await Promise.all([
    prisma.entity.findMany({
      where,
      skip,
      take: limit,
      orderBy: { [sortBy]: sortOrder },
    }),
    prisma.entity.count({ where }),
  ]);

  return { data, total };
}
```

---

## 5. Validation Schema

```typescript
import { z } from 'zod';

export const paginationQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.string().default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});
```

---

## 6. Rules

1. **Always** use `Promise.all` for parallel count + data queries.
2. **Never** allow `limit` > 100 — enforce in validation.
3. Return **full pagination metadata** — clients should never need to calculate.
4. Default sort is `createdAt desc` (newest first).
5. Use cursor-based pagination only when explicitly needed (infinite scroll, real-time).
