#  BackendBot — Architecture Blueprint

 **Single Source of Truth for Back Office API Architectures.**

BackendBot is an industry-grade, schema-driven blueprint repository designed to define, structure, and document Back Office Express/TypeScript APIs. It provides a set of standardized project instructions that can be synced to your local machine for use with AI coding assistants.

---

## Features at a Glance

- **Standardized Blueprints**: Access standard backend blueprints for any project.
- **Local Sync Engine**: Easily clone or update the blueprints on your machine using the installation script.
- **AI-Agent Ready**: Immutable guidelines structured specifically for AI-assisted development tools (like Gemini, Cursor, etc.).
- **Comprehensive Standard**: Includes 19 rigorous, production-tested blueprint files.

---

## Quick Start for Developers

You can clone and sync these blueprints to your local project directory (`.backend-blueprints`) with a single terminal command.

### Installation / Update
Run this command inside your backend project folder to install or update the standard project instructions:
```bash
curl -sSL https://raw.githubusercontent.com/bochamaakram/backendbot/main/install.sh | bash
```

This will clone or pull the latest changes from the repository into your local `.backend-blueprints` directory, making them easily accessible for your AI agents for the current project.

---

## Production-Ready Blueprints (19 Specifications)

The repository contains the following comprehensive architectural specifications in the `docs/schema/` directory:

| Blueprint Specification | Domain | Purpose & Scope |
| :--- | :--- | :--- |
| `_overview.md` | **Meta** | High-level request lifecycle, folder structures, and file indexes |
| `_conventions.md` | **Meta** | Strict naming conventions, import sorting, ESLint/TS configs, and commit rules |
| `_database.md` | **Data** | Prisma ORM schemas, migration guides, and data seeding patterns |
| `_authentication.md` | **Auth** | Clerk token verification, real-time webhooks, and local database sync |
| `_authorization.md` | **Auth** | Role-Based Access Control (RBAC), guards, and custom token claims |
| `_error_handling.md` | **Core** | Standardized custom error hierarchy, mapper helpers, and global middleware |
| `_validation.md` | **Core** | Type-safe body/query request validation patterns with Zod |
| `_api_response.md` | **Core** | Standardized JSON envelope contract for successes, errors, and paginated lists |
| `_audit.md` | **Core** | Relational append-only mutations auditing and secure service logging |
| `_environment.md` | **Core** | Strict type-safe environment variable assertions using schema checkers |
| `_file_upload.md` | **Core** | Streamlined file-handling, multer constraints, and database record mappings |
| `_logging.md` | **Core** | Multi-transport logging patterns (Winston) and request context injection |
| `_middleware.md` | **Core** | Request-ID correlation, CORS rules, and secure HTTP headers |
| `_modules.md` | **Core** | Scalable route/controller/service/repository domain scaffold guidelines |
| `_pagination.md` | **Core** | Standardized cursor and limit-offset parameter contracts |
| `_rate_limiting.md` | **Core** | Security rate limits using memory and Redis store fallback plans |
| `_security.md` | **Core** | OWASP API guidelines, helmet rules, and data sanitize checks |
| `_testing.md` | **Core** | Integration testing setups, service mocks, and unit coverage guidelines |
| `_deployment.md` | **DevOps** | Production Docker configuration and standardized health check metrics |

---

## AI Agent Integration

These blueprints are explicitly designed to serve as **immutable rules** for AI-assisted development (such as Gemini, Claude, ChatGPT, or Cursor). 

Before generating code inside your project, simply instruct your AI assistant:

> *"Before starting, read `.backend-blueprints/docs/schema/_overview.md` and adhere to all architectural boundaries, code conventions, schemas, and API response rules defined in `.backend-blueprints/docs/schema/`."*

