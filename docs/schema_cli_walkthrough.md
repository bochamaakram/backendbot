# 📖 Walkthrough: Using the BackendBot CLI

This guide will walk you through how to use the custom `backendbot` command line interface to rapidly seed any backend project with your standardized Back Office schemas.

---

## 🧭 Overview of the Command

The custom `backendbot` CLI command resides at [backendbot](file:///home/akram/.local/bin/backendbot) and is connected directly to your source schemas inside [backendbot/docs/schema](file:///home/akram/Desktop/personal/backendbot/docs/schema). 

When run inside any target directory, it automatically initializes a `docs/schema/` structure filled with your immutable backend specifications.

---

## ⚡ Step-by-Step Guide

### Step 1: Ensure Your Terminal Session is Refreshed
Because the command was recently added to your `~/.local/bin` directory, make sure your shell path is active. If you are in an existing terminal window, either restart it or run:
```bash
source ~/.zshrc
```

### Step 2: Navigate to Your Target Project
Navigate to any backend repository where you want to add the Back Office database, auth, error-handling, or validation rules. For example:
```bash
cd ~/Desktop/personal/my-new-api
```

### Step 3: Run the Command

To copy all architecture schemas into the current folder, run:
```bash
backendbot init
```

> [!TIP]
> You can also just type `backendbot` with no arguments inside a folder that doesn't have the schemas yet, and it will automatically start the initialization process for you!

#### Expected Successful Output:
```text
┌────────────────────────────────────────────────────────┐
│  ✨  BackendBot — Schema Architect CLI                 │
└────────────────────────────────────────────────────────┘
🔵 Preparing to inject schemas to: /home/akram/Desktop/personal/my-new-api
⚡ Syncing schemas...

🟢 Success! Backend schemas successfully integrated!

Generated Blueprint Files:
  📁 _api_response.md
  📁 _audit.md
  📁 _authentication.md
  ...
  📁 _validation.md

✨ Your AI agents and developers now have an authoritative blueprint at docs/schema/.
```

---

## 🛡️ Overwrite Protection & Safety

If you run the command inside a project that already has a `docs/schema` directory, `backendbot` will safely warn you and ask for confirmation before modifying or overwriting your current files:

```text
⚠️  Warning: 'docs/schema' already exists in this project.
👉 Do you want to overwrite existing schema files? (y/N) 
```
* Pressing `y` or `Y` will overwrite the files with the latest source schemas.
* Pressing any other key will safely abort the process.

---

## 🔍 Checking Installation Status

At any point, you can verify if a project has the schemas installed and check the count of documentation files by running:

```bash
backendbot status
```

#### If Installed:
```text
🟢 BackendBot schemas are INSTALLED in this project.
  📁 Location:   /home/akram/Desktop/personal/my-new-api/docs/schema
  ⚡ File Count: 19 documentation specifications
```

#### If Not Installed:
```text
🔴 BackendBot schemas are NOT installed in this project.
👉 Run backendbot init inside this directory to integrate them.
```

---

## 🤖 Best Practices for AI Coding Assistants

Once you have integrated the schemas into your active project, we recommend instructing any coding assistant (like Gemini or others) to read them first. 

Add a note like this to your prompt or system instructions:
> *"Please read `docs/schema/_overview.md` and follow the architectural rules and file guidelines defined there before writing any code."*
