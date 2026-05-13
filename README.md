# 📐 BackendBot — Architecture Blueprint & CLI Sync

> **Single Source of Truth for Back Office API Architectures.**

BackendBot is an industry-grade, schema-driven blueprint repository designed to define, structure, and document Back Office Express/TypeScript APIs. It features an integrated, cross-platform **Node.js CLI tool** that enables developers to instantly inject and synchronize these strict architectural standards into any backend repository on their local system.

---

## 💎 Features at a Glance

- 🚀 **Zero-Config Seed**: Initialize standard backend blueprints in seconds.
- 🔄 **Local Sync Engine**: Symlinked or globally registered via Node (`npm link`) for instant blueprint updates.
- 🛡️ **Overwrite Protection**: Interactive CLI guards prevent accidental data loss in target projects.
- 🤖 **AI-Agent Ready**: Immutable guidelines structured specifically for AI-assisted development tools (like Gemini, Cursor, etc.).
- 📐 **Comprehensive Standard**: Includes 19 rigorous, production-tested blueprint files.

---

## 🚀 Quick Start for Developers

You can register and use these blueprints in your own projects with just a few terminal commands.

### 1. Clone the Repository
Clone this repository to any location on your local machine:
```bash
git clone https://github.com/bochamaakram/backendbot.git
cd backendbot
```

### 2. Install the Global CLI Command
Register the global `backendbot` command on **any** operating system (Windows, macOS, or Linux) using your terminal:

```bash
npm link
```

- **On Windows**: Run the command in PowerShell or Command Prompt. NPM will configure natively compatible executable wrappers (`backendbot.cmd` / `backendbot.ps1`).
- **On macOS / Linux**: Run `npm link` (or use `./install.sh` as a shell helper).

> [!NOTE]
> Both methods dynamically symlink the executable, meaning any schema updates pulled via `git pull` are instantly active without needing reinstallations.

---

## 🛠️ CLI Command Reference

Once installed, use the command from inside **any** backend project directory on your machine.

### `backendbot init`
To inject the full standardized `docs/schema/` structure into your active project, navigate to the target project directory and run:
```bash
backendbot init
```
*(Or simply type `backendbot` with no arguments, and the CLI will guide you dynamically!)*

### `backendbot status`
To verify if schemas are currently integrated and see the file count inside your active project, run:
```bash
backendbot status
```

### `backendbot help`
To print interactive help guidelines and command details, run:
```bash
backendbot help
```

---

## 🛡️ Overwrite Protection & Safeguards

To prevent accidental data loss, the CLI prompts for confirmation before overwriting any pre-existing schemas:

```text
⚠️  Warning: 'docs/schema' already exists in this project.
👉 Do you want to overwrite existing schema files? (y/N) 
```

- **Dynamic Path Resolution**: The CLI command resolves its origin folder relative to where the binary resides, making it fully location-independent on your filesystem.
- **Smart Symlinks**: Since the executable is symlinked, any `git pull` updates pulled down into the `backendbot` repository are reflected immediately across all target projects on the next run!

---

## 📂 Production-Ready Blueprints (19 Specifications)

Upon initialization, the CLI creates a `docs/schema/` directory containing the following comprehensive architectural specifications:

| Blueprint Specification | Domain | Purpose & Scope |
| :--- | :--- | :--- |
| [`_overview.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_overview.md) | **Meta** | High-level request lifecycle, folder structures, and file indexes |
| [`_conventions.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_conventions.md) | **Meta** | Strict naming conventions, import sorting, ESLint/TS configs, and commit rules |
| [`_database.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_database.md) | **Data** | Prisma ORM schemas, migration guides, and data seeding patterns |
| [`_authentication.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_authentication.md) | **Auth** | Clerk token verification, real-time webhooks, and local database sync |
| [`_authorization.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_authorization.md) | **Auth** | Role-Based Access Control (RBAC), guards, and custom token claims |
| [`_error_handling.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_error_handling.md) | **Core** | Standardized custom error hierarchy, mapper helpers, and global middleware |
| [`_validation.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_validation.md) | **Core** | Type-safe body/query request validation patterns with Zod |
| [`_api_response.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_api_response.md) | **Core** | Standardized JSON envelope contract for successes, errors, and paginated lists |
| [`_audit.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_audit.md) | **Core** | Relational append-only mutations auditing and secure service logging |
| [`_environment.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_environment.md) | **Core** | Strict type-safe environment variable assertions using schema checkers |
| [`_file_upload.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_file_upload.md) | **Core** | Streamlined file-handling, multer constraints, and database record mappings |
| [`_logging.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_logging.md) | **Core** | Multi-transport logging patterns (Winston) and request context injection |
| [`_middleware.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_middleware.md) | **Core** | Request-ID correlation, CORS rules, and secure HTTP headers |
| [`_modules.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_modules.md) | **Core** | Scalable route/controller/service/repository domain scaffold guidelines |
| [`_pagination.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_pagination.md) | **Core** | Standardized cursor and limit-offset parameter contracts |
| [`_rate_limiting.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_rate_limiting.md) | **Core** | Security rate limits using memory and Redis store fallback plans |
| [`_security.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_security.md) | **Core** | OWASP API guidelines, helmet rules, and data sanitize checks |
| [`_testing.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_testing.md) | **Core** | Integration testing setups, service mocks, and unit coverage guidelines |
| [`_deployment.md`](file:///home/akram/Desktop/personal/backendbot/docs/schema/_deployment.md) | **DevOps** | Production Docker configuration and standardized health check metrics |

---

## 🤖 AI Agent Integration

These blueprints are explicitly designed to serve as **immutable rules** for AI-assisted development (such as Gemini, Claude, ChatGPT, or Cursor). 

Before generating code inside your project, simply instruct your AI assistant:

> 💡 *"Before starting, read `docs/schema/_overview.md` and adhere to all architectural boundaries, code conventions, schemas, and API response rules defined in `docs/schema/`."*

