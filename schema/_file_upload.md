# 📁 File Upload Handling

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Library | Multer |
| Storage (dev) | Local filesystem (`./uploads/`) |
| Storage (prod) | Cloud storage (S3/GCS) via adapter |
| Max file size | Configurable via `UPLOAD_MAX_SIZE_MB` |
| Allowed types | Configurable via `UPLOAD_ALLOWED_TYPES` |

---

## 2. Upload Middleware

```typescript
// src/common/middleware/upload.middleware.ts
import multer from 'multer';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import { config } from '@config/index.js';
import { ValidationError } from '@common/errors/index.js';

const storage = multer.diskStorage({
  destination: config.UPLOAD_DEST,
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${randomUUID()}${ext}`);
  },
});

const fileFilter: multer.Options['fileFilter'] = (_req, file, cb) => {
  // NOTE: This basic check relies on the client's Content-Type header.
  // It MUST be supplemented by a subsequent magic-bytes validation (e.g., using `file-type`)
  // after the file buffer is received or saved, to prevent malicious file uploads (e.g., .php masked as .jpg).
  const allowed = config.UPLOAD_ALLOWED_TYPES.split(',');
  const isAllowed = allowed.some((type) => {
    if (type.endsWith('/*')) {
      return file.mimetype.startsWith(type.replace('/*', '/'));
    }
    return file.mimetype === type;
  });

  if (!isAllowed) {
    cb(new ValidationError(`File type ${file.mimetype} not allowed`));
    return;
  }
  cb(null, true);
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: config.UPLOAD_MAX_SIZE_MB * 1024 * 1024 },
});
```

### Usage

```typescript
// Single file
router.post('/avatar', authGuard, upload.single('avatar'), controller.uploadAvatar);

// Multiple files
router.post('/gallery', authGuard, upload.array('images', 10), controller.uploadGallery);
```

---

## 3. File Metadata Model

```prisma
model File {
  id           String   @id @default(uuid())
  filename     String   // UUID-based filename on disk
  originalName String   // User's original filename
  mimeType     String
  size         Int      // Bytes
  path         String   // Storage path or URL
  uploadedById String
  createdAt    DateTime @default(now())

  @@index([uploadedById])
}
```

---

## 4. Rules

1. **Never** trust the original filename — generate UUID-based names.
2. **Always** validate MIME type server-side using **magic-bytes** inspection (e.g., using a library like `file-type`). **Never** rely on the file extension or the `Content-Type` header provided by the client. The system must actively detect and reject malicious files masked with safe extensions (e.g., a PHP script masked as a `.jpg`).
3. **Never** serve uploaded files from the application directly — use a static file server or CDN.
4. Store file metadata in the database, not just the filesystem.
5. Implement cleanup for orphaned files (uploaded but not linked to any entity).
