# 📐 BackendBot — Architecture Blueprint & CLI Sync

> **Single Source of Truth for Back Office API Architectures.**

BackendBot is a schema-driven blueprint repository designed to define, structure, and document Back Office Express/TypeScript APIs. It includes an integrated **portable CLI tool** that allows developers to easily copy and synchronize these architectural standards into any target repository on their local system.

---

## 🚀 Quick Start for Developers

Anyone can copy and use these blueprints in their own projects with just a few simple terminal commands.

### 1. Clone the Repository
Clone this repository to any location on your local machine:
```bash
git clone https://github.com/bochamaakram/backendbot.git
cd backendbot
```

### 2. Install the Global CLI Command
Run the universal installer script:
```bash
./install.sh
```

This installer will:
1. Make the CLI engine executable.
2. Automatically create a global symbolic link inside your local user path (`~/.local/bin/backendbot`) pointing directly to your local clone.

---

## 🛠️ Usage inside Target Projects

Once installed, you can use the command from inside **any** backend project directory on your machine.

### Seed Architectural Schemas
To inject the full standardized `docs/schema/` structure into your active project, navigate to the project directory and run:
```bash
backendbot init
```
*(Or simply type `backendbot` with no arguments, and the CLI will guide you dynamically!)*

### Check Sync Status
To verify if schemas are currently integrated and see the file count inside your active project, run:
```bash
backendbot status
```

---

## 🛡️ Key CLI Features

* **Dynamic Path Resolution**: The command resolves its origin folder relative to where it resides, making it completely location-independent.
* **Smart Override Safeguards**: To prevent accidental data loss, the CLI prompts for confirmation before overwriting any pre-existing schemas.
* **Up-to-Date Blueprints**: Since the command is symlinked, any `git pull` updates you pull down into this repository are reflected immediately across all projects next time you run `backendbot init`—no reinstallation required!

---

## 📂 Architecture Schemas Included

Upon initialization, the CLI creates a `docs/schema/` directory containing the following:

| Core Blueprint File | Domain | Purpose |
| :--- | :--- | :--- |
| `_overview.md` | Meta | High-level request lifecycle & file index |
| `_conventions.md` | Meta | Directory layout, styling, and coding practices |
| `_database.md` | Data | Prisma schemas, migration, and seeding patterns |
| `_authentication.md` | Auth | Clerk integration & database syncing webhook |
| `_authorization.md` | Auth | Role-Based Access Control (RBAC) schemas |
| `_error_handling.md` | Core | Standardized taxonomy and error contract |
| `_validation.md` | Core | Zod request/response validation patterns |
| ... | *and 12 more* | *Detailed coverage of CORS, Logging, Pagination, etc.* |

---

## 🤖 AI Agent Compatibility
These schemas are explicitly designed to act as **immutable instructions** for AI-assisted development tools. Simply instruct your AI agent:
> *"Before starting, read `docs/schema/_overview.md` and adhere to all architectural structures, boundaries, and validation conventions defined there."*
