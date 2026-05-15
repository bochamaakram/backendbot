# 📁 Application File Structure

> **Status:** Source of Truth  
> **Last Updated:** 2026-05-15

---

## 1. Project Root Layout

Every full-stack application following this blueprint **MUST** adhere to the following top-level directory structure. This ensures consistency across development environments and CI/CD pipelines.

```
app_name/
├── .backend-blueprints/     # Cloned architectural specifications (Source of Truth)
│   └── schema/              # This directory
├── backend/                 # Node.js / Express / TypeScript API
│   ├── prisma/              # Database schema & migrations
│   ├── src/                 # Application source code
│   ├── Dockerfile           # Backend container definition
│   └── package.json
├── frontend/                # React / Next.js / Mobile Application
│   ├── src/                 # UI source code
│   ├── Dockerfile           # Frontend container definition
│   └── package.json
├── docker-compose.yml       # Orchestrates backend, frontend, and database
└── README.md                # Project entry point
```

---

## 2. Key Directories

### 📍 `.backend-blueprints/schema`
Contains the immutable architectural rules for the project. The AI agent **must** read these before making any changes to the code.

### 📍 `backend/`
The core API. All logic within this directory must follow the patterns defined in `_modules.md`, `_error_handling.md`, and other schema files.

### 📍 `frontend/`
The user interface. While the current blueprints focus on the backend, the frontend should reside in this sibling directory to maintain a clean monorepo-style separation.

---

## 3. Agent Instructions

1. **Verify Context**: Before starting any task, verify that you are working within the correct sub-directory (`backend` or `frontend`).
2. **Absolute Paths**: When referencing architectural rules, always look in `.backend-blueprints/schema/`.
3. **Consistency**: Do not create top-level directories other than those specified above without explicit user approval.
