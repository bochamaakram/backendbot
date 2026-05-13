# 🧩 Module Generation Pattern

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Module Scaffold

Every feature module lives in `src/modules/<module-name>/` and contains **exactly** these files:

```
src/modules/<module-name>/
├── <module>.routes.ts       # Route definitions
├── <module>.controller.ts   # Request handling (thin)
├── <module>.service.ts      # Business logic
├── <module>.repository.ts   # Data access (Prisma)
├── <module>.validator.ts    # Zod validation schemas
├── <module>.types.ts        # TypeScript types & DTOs
└── __tests__/
    ├── <module>.service.test.ts
    ├── <module>.controller.test.ts
    └── <module>.factory.ts
```

---

## 2. Layer Templates

### 2.1 Routes

```typescript
// src/modules/product/product.routes.ts
import { Router } from 'express';
import { authGuard } from '@common/guards/auth.guard.js';
import { syncUserMiddleware } from '@common/middleware/sync-user.middleware.js';
import { requirePermission } from '@common/guards/permission.guard.js';
import { validate } from '@common/middleware/validate.middleware.js';
import { productController } from './product.controller.js';
import {
  createProductSchema,
  updateProductSchema,
  getProductSchema,
  listProductsSchema,
} from './product.validator.js';

export const productRouter = Router();

// All routes: authGuard (Clerk) → syncUser → permission → validate → handler
productRouter.post(
  '/',
  authGuard,
  syncUserMiddleware,
  requirePermission('product:create'),
  validate(createProductSchema),
  productController.create,
);

productRouter.get(
  '/',
  authGuard,
  syncUserMiddleware,
  requirePermission('product:read'),
  validate(listProductsSchema),
  productController.findAll,
);

productRouter.get(
  '/:id',
  authGuard,
  syncUserMiddleware,
  requirePermission('product:read'),
  validate(getProductSchema),
  productController.findById,
);

productRouter.patch(
  '/:id',
  authGuard,
  syncUserMiddleware,
  requirePermission('product:update'),
  validate(updateProductSchema),
  productController.update,
);

productRouter.delete(
  '/:id',
  authGuard,
  syncUserMiddleware,
  requirePermission('product:delete'),
  validate(getProductSchema),
  productController.delete,
);
```

### 2.2 Controller

```typescript
// src/modules/product/product.controller.ts
import { Request, Response, NextFunction } from 'express';
import { ApiResponse } from '@common/utils/api-response.js';
import { ProductService } from './product.service.js';

const productService = new ProductService();

export const productController = {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await productService.create(req.body, req.localUser!);
      ApiResponse.created(res, req, result);
    } catch (error) {
      next(error);
    }
  },

  async findAll(req: Request, res: Response, next: NextFunction) {
    try {
      const { data, total } = await productService.findAll(req.query);
      ApiResponse.paginated(res, req, data, {
        page: Number(req.query.page),
        limit: Number(req.query.limit),
        total,
      });
    } catch (error) {
      next(error);
    }
  },

  async findById(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await productService.findById(req.params.id);
      ApiResponse.success(res, req, result);
    } catch (error) {
      next(error);
    }
  },

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await productService.update(req.params.id, req.body, req.localUser!);
      ApiResponse.success(res, req, result);
    } catch (error) {
      next(error);
    }
  },

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      await productService.delete(req.params.id, req.localUser!);
      ApiResponse.noContent(res);
    } catch (error) {
      next(error);
    }
  },
};
```

### 2.3 Service

```typescript
// src/modules/product/product.service.ts
import { ProductRepository } from './product.repository.js';
import { NotFoundError, ConflictError } from '@common/errors/index.js';
import { auditLogger } from '@common/utils/audit.js';
import type { CreateProductDto, UpdateProductDto, ListProductsQuery } from './product.types.js';
import type { UserWithRole } from '@common/types/express.js';

const productRepository = new ProductRepository();

export class ProductService {
  async create(data: CreateProductDto, actor: UserWithRole) {
    const product = await productRepository.create(data);
    await auditLogger.log('create', 'product', product.id, actor, null, product);
    return product;
  }

  async findAll(query: ListProductsQuery) {
    return productRepository.findAll(query);
  }

  async findById(id: string) {
    const product = await productRepository.findById(id);
    if (!product) throw new NotFoundError(`Product ${id} not found`);
    return product;
  }

  async update(id: string, data: UpdateProductDto, actor: UserWithRole) {
    const existing = await this.findById(id);
    const updated = await productRepository.update(id, data);
    await auditLogger.log('update', 'product', id, actor, existing, updated);
    return updated;
  }

  async delete(id: string, actor: UserWithRole) {
    const existing = await this.findById(id);
    await productRepository.delete(id);
    await auditLogger.log('delete', 'product', id, actor, existing, null);
  }
}
```

### 2.4 Repository

```typescript
// src/modules/product/product.repository.ts
import { prisma } from '@config/database.js';
import { mapPrismaError } from '@common/errors/prisma-error.mapper.js';
import { Prisma } from '@prisma/client';
import type { CreateProductDto, UpdateProductDto, ListProductsQuery } from './product.types.js';

export class ProductRepository {
  async create(data: CreateProductDto) {
    try {
      return await prisma.product.create({ data });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        throw mapPrismaError(error);
      }
      throw error;
    }
  }

  async findAll(query: ListProductsQuery) {
    const { page, limit, sortBy, sortOrder, search } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.ProductWhereInput = search
      ? { name: { contains: search, mode: 'insensitive' } }
      : {};

    const [data, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
      }),
      prisma.product.count({ where }),
    ]);

    return { data, total };
  }

  async findById(id: string) {
    return prisma.product.findUnique({ where: { id } });
  }

  async update(id: string, data: UpdateProductDto) {
    try {
      return await prisma.product.update({ where: { id }, data });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        throw mapPrismaError(error);
      }
      throw error;
    }
  }

  async delete(id: string) {
    try {
      await prisma.product.delete({ where: { id } });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        throw mapPrismaError(error);
      }
      throw error;
    }
  }
}
```

---

## 3. Route Registration

Every new module must be registered in the central router:

```typescript
// src/routes.ts
import { Router } from 'express';
import { userRouter } from '@modules/user/user.routes.js';
import { productRouter } from '@modules/product/product.routes.js';
import { clerkWebhookRouter } from '@modules/webhook/clerk-webhook.routes.js';

export const apiRouter = Router();

apiRouter.use('/users', userRouter);
apiRouter.use('/products', productRouter);
// Add new modules here

// Webhooks (outside API prefix, no auth)
// Registered separately in app.ts:
// app.use('/webhooks', clerkWebhookRouter);
```

---

## 4. Checklist for New Modules

- [ ] Create module directory with all 6 files + `__tests__/`
- [ ] Add Prisma model to `schema.prisma`
- [ ] Run `prisma migrate dev --name add-<module>`
- [ ] Add permissions to `_authorization.md` matrix
- [ ] Seed new permissions in `prisma/seed.ts`
- [ ] Register routes in `src/routes.ts`
- [ ] Write unit tests for service layer
- [ ] Write integration tests for routes
