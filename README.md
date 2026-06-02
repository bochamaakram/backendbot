#  BackendBot — Architecture Blueprint

**Single Source of Truth for Back Office API Architectures.**

BackendBot is an industry-grade, schema-driven blueprint repository designed to define, structure, and document Back Office Express/TypeScript APIs. It provides a set of standardized project instructions that can be synced to your local machine for use with AI coding assistants.

---

## Features at a Glance

- **Standardized Blueprints**: 22 production-tested backend architecture specifications.
- **Bundled UI/UX Skill**: Includes the [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) AI design intelligence skill (67 UI styles, 161 palettes, 57 font pairings, 99 UX guidelines, and a design system generator).
- **Local Sync Engine**: Easily install or update blueprints with the interactive installer.
- **AI-Agent Ready**: Immutable guidelines structured for AI-assisted development tools (Gemini, Claude, Cursor, Copilot, etc.).

---

## Quick Start for Developers

Run this inside your backend project folder:

```bash
curl -sSL https://raw.githubusercontent.com/bochamaakram/backendbot/main/install.sh | bash
```

The installer runs a **two-step wizard**:

**Step 1 — Backend Blueprints** (pick one):
- `1` All Blueprints — Complete 22-specification suite *(recommended)*
- `2` Category-based — Choose by category (Meta, Auth, Data, Core API, DevOps, SEO/GEO)
- `3` Custom — Select individual blueprints one by one

**Step 2 — UI/UX Pro Max Skill** *(optional, default: yes)*:
- Installs the design intelligence skill into `.backend-blueprints/skills/ui-ux-pro-max/`
- Gives your AI access to 67 UI styles, 161 color palettes, 57 font pairings, and a reasoning-based design system generator

After installation, prompt your AI agent:

```
Before starting, read `.backend-blueprints/schema/_overview.md` and adhere to all
architectural boundaries, code conventions, schemas, and API response rules defined
in `.backend-blueprints/schema/`. Also read `.backend-blueprints/skills/ui-ux-pro-max/SKILL.md`
for UI/UX design intelligence.
```

---

## What Gets Installed

```
.backend-blueprints/
├── schema/                        ← Backend architecture blueprints
│   ├── _overview.md
│   ├── _authentication.md
│   └── ... (up to 22 files)
└── skills/                        ← Bundled AI skills
    └── ui-ux-pro-max/
        ├── SKILL.md               ← AI design intelligence rules
        ├── scripts/
        │   ├── search.py          ← Design system generator (requires Python 3)
        │   └── design_system.py
        └── data/
            ├── styles.csv         ← 67 UI styles
            ├── colors.csv         ← 161 color palettes
            ├── typography.csv     ← 57 font pairings
            ├── ux-guidelines.csv  ← 99 UX guidelines
            └── ...
```

---

## Production-Ready Blueprints (22 Specifications)

| Blueprint Specification | Domain | Purpose & Scope |
| :--- | :--- | :--- |
| `_overview.md` | **Meta** | High-level request lifecycle, folder structures, and file indexes |
| `_filestructure.md` | **Meta** | Standardized high-level project file structure |
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
| `_seo.md` | **Core** | Standardized SEO metadata, JSON-LD generation, sitemaps, and robots directives |
| `_geo.md` | **Core** | Generative Engine Optimization (GEO) rules for AI search citations |
| `_testing.md` | **Core** | Integration testing setups, service mocks, and unit coverage guidelines |
| `_deployment.md` | **DevOps** | Production Docker configuration and standardized health check metrics |

---

## Bundled Skill: UI/UX Pro Max

The installer optionally bundles the [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) skill (86k+ ⭐) directly into your project — no extra tools required.

| Feature | Details |
| :--- | :--- |
| **Design System Generator** | AI reasoning engine that generates complete, tailored design systems |
| **67 UI Styles** | Glassmorphism, Claymorphism, Minimalism, Brutalism, Neumorphism, Bento Grid, Dark Mode, and more |
| **161 Color Palettes** | Industry-specific, curated palettes aligned to 161 product categories |
| **57 Font Pairings** | Google Fonts typography combinations with mood & use-case guidance |
| **99 UX Guidelines** | Best practices, anti-patterns, and accessibility rules |
| **Python Search Engine** | `search.py` — query any domain (styles, typography, charts, stacks) |

> [!NOTE]
> The Python search engine (`search.py`) requires Python 3. The `SKILL.md` file works standalone without Python — just read it with your AI.

### Using the UI/UX Skill

After install, prompt your AI:

```
I am building the [Page Name] page. Read .backend-blueprints/skills/ui-ux-pro-max/SKILL.md
for UI/UX design intelligence and generate a complete design system before writing code.
```

Or run the design system generator directly:

```bash
python3 .backend-blueprints/skills/ui-ux-pro-max/scripts/search.py "SaaS dashboard" --design-system -p "MyApp"
```

---

## AI Agent Integration

These blueprints are designed to serve as **immutable rules** for AI-assisted development (Claude, Gemini, ChatGPT, Cursor, Copilot, etc.).

Before generating code, instruct your AI:

> *"Before starting, read `.backend-blueprints/schema/_overview.md` and adhere to all architectural boundaries, code conventions, schemas, and API response rules defined in `.backend-blueprints/schema/`. Also read `.backend-blueprints/skills/ui-ux-pro-max/SKILL.md` for UI/UX design intelligence."*

