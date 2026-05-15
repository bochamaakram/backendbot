# 📋 Structured Logging

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-13

---

## 1. Strategy

| Aspect | Decision |
|--------|----------|
| Library | Winston (or Pino) |
| Format (dev) | Pretty-printed, colorized |
| Format (prod) | JSON (structured, machine-parseable) |
| Correlation | Every log line includes `requestId` |
| Sensitive data | **Never** logged — tokens, passwords, PII are masked |

---

## 2. Logger Configuration

```typescript
// src/config/logger.ts
import winston from 'winston';
import { config } from '@config/index.js';

const devFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    const metaStr = Object.keys(meta).length ? JSON.stringify(meta, null, 2) : '';
    return `${timestamp} ${level}: ${message} ${metaStr}`;
  }),
);

const prodFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.json(),
);

export const logger = winston.createLogger({
  level: config.LOG_LEVEL,
  format: config.LOG_FORMAT === 'pretty' ? devFormat : prodFormat,
  defaultMeta: { service: config.APP_NAME },
  transports: [new winston.transports.Console()],
});
```

---

## 3. Log Levels

| Level | Usage |
|-------|-------|
| `error` | Unrecoverable failures, unhandled exceptions |
| `warn` | Operational errors (4xx), deprecations, retries |
| `info` | Request lifecycle, startup, shutdown, key events |
| `debug` | Detailed traces, Prisma queries (dev only) |

---

## 4. Standard Log Fields

Every log entry should include applicable fields:

```json
{
  "timestamp": "2026-05-13T10:00:00.000Z",
  "level": "info",
  "service": "BackOffice",
  "requestId": "abc-123-def",
  "message": "request completed",
  "method": "POST",
  "path": "/api/v1/users",
  "statusCode": 201,
  "duration": "45ms",
  "userId": "user-uuid",
  "ip": "192.168.1.1"
}
```

---

## 5. Sensitive Data Masking

```typescript
// src/common/utils/mask.ts
export const maskToken = (token: string): string => {
  if (token.length <= 8) return '****';
  return `${token.slice(0, 4)}...${token.slice(-4)}`;
};

export const maskEmail = (email: string): string => {
  const [user, domain] = email.split('@');
  return `${user[0]}***@${domain}`;
};
```

**Never log:** passwords, tokens, credit cards, full emails, or request bodies containing sensitive fields.

---

## 6. Rules

1. Use `logger` from `@config/logger.js` — never `console.log`.
2. Every log must include `requestId` when inside a request context.
3. Log at the **right level** — don't use `error` for expected failures.
4. Mask all sensitive data before logging.
5. Log request start/end in middleware, not in controllers.
