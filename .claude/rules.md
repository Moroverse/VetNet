
# 📘 Clean Code Rules for SwiftUI Projects using Claude Code

This document defines a comprehensive set of clean code rules and automated workflows for SwiftUI projects utilizing the Claude Code platform.

---

## 🛠 1. Code Style and Consistency

- ✅ **Always use Swift Format** after each code change:
  - Triggered at `PostToolUse` (e.g., after `Edit`, `MultiEdit`)
  - Tool: `Bash` → `swiftformat .`

- ✅ **Lint Swift files** on every edit to enforce code quality:
  - Tool: `Bash` → `swiftlint`
  - Automatically run on `PostToolUse`

- ✅ **Follow Swift API Design Guidelines**:
  - Clear naming (`camelCase`, verbs for actions, nouns for objects)
  - Prefer immutability (`let` > `var`)
  - Use trailing closures where appropriate

- ✅ **Standardize file structure and naming**:
  - All SwiftUI views must be named with a `View` suffix (e.g., `LoginView.swift`)
  - Models in `/Models`, views in `/Views`, helpers in `/Utils`

---

## 🔍 2. Tooling and Project-Wide Operations

- 📖 **Read** source files before edits to preserve patterns
  - Tool: `Read`
  - Execution Point: `PreToolUse`

- 🔁 **Use `MultiEdit`** for batch updates during refactors
  - E.g., Rename `@State` properties project-wide
  - Tool: `MultiEdit`

- 🔎 **Use `Grep` or `Glob`** to:
  - Find unused code (`func`, `var`, `class` not referenced)
  - Detect deprecated API usage
  - Tool: `Grep`, `Glob`

---

## ✅ 3. Test-Driven Development and Build Validation

- 🧪 **Run tests automatically after code changes**:
  - Tool: `Bash` → `tuist test` --platform ios
  - Execution Point: `PostToolUse`
- 🏗 **Run `tuist generate` after files are added or removed in porject directory **:
  - Ensures most recent project structure
  - Tool: `Bash` → `tuist generate`
  - Execution Point: `PostToolUse`
- 🏗 **Run `tuist build` after file updates**:
  - Ensures no build regressions
  - Tool: `Bash` → `tuist build` --platform ios
  - Execution Point: `PostToolUse`
- 📈 **Generate test coverage reports**:
  - Tool: `Bash` → `tuist test`
  - Execution Point: `Stop`
- 🧩 **Validate Info.plist and signing settings**:
  - Tool: `Read` + `Bash` for plist parsing
  - Execution Point: `PreToolUse` for environment setup

---

## 🧹 4. Documentation and Code Comments

- 📄 **Auto-generate documentation** from code comments:
  - Tool: `Bash` or external doc generator via `WebFetch`
  - Execution Point: `PostToolUse`

- 🔍 **Scan for missing or outdated doc comments**:
  - Tool: `Grep`
  - Execution Point: `PreCompact`

- 🚨 **Enforce header comments for public classes**:
  - Tool: `Grep` + `Edit`
  - Rule: All public Swift types must have documentation

---

## 🔐 5. Security and Safety Checks

- 🛑 **Validate file paths and avoid sensitive file writes**:
  - Execution Point: `PreToolUse`
  - Rule: Never overwrite `.env`, `Secrets.plist`, or `Info.plist` without confirmation

- 🚫 **Reject code with hardcoded credentials**:
  - Tool: `Grep`
  - Rule: Detect patterns like `let password =`, `API_KEY =`

---

## 🔄 6. Workflow Automation with Execution Points

| **Execution Point** | **Automated Rules** |
|---------------------|---------------------|
| `PreToolUse`        | Validate files, run security checks, load config |
| `PostToolUse`       | Run linters, formatters, build system, run tests |
| `Stop`              | Run full test suite, summarize changes, commit |
| `SessionStart`      | Load project settings and environment variables |
| `UserPromptSubmit`  | Enhance prompt with context and documentation |
| `SubagentStop`      | Merge subtask results and clean up |
| `Notification`      | Alert on critical errors, ask for permission |
| `PreCompact`        | Backup important context and user decisions |

---

## 🌍 7. External Integration

- 🌐 **Use `WebSearch`** to:
  - Find Swift best practices
  - Investigate error messages
  - Execution Point: `UserPromptSubmit`

- 📥 **Use `WebFetch`** to:
  - Retrieve remote documentation or JSON examples
  - Fetch external API schemas

---

## 💡 8. Developer Practices

- 🧠 **Always check patterns before writing new components** using:
  - `Read`, `Grep`, `Glob` at `PreToolUse`

- 🪄 **Use `Task` for complex workflows**, such as:
  - Creating a new feature module
  - Migrating from UIKit to SwiftUI

- ♻️ **Refactor regularly** using `MultiEdit` and `Glob`

---
