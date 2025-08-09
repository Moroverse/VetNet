# 📘 Clean Code Rules for SwiftUI Projects using Claude Code with TDD

This document defines a comprehensive set of clean code rules, TDD principles, and automated workflows for SwiftUI projects utilizing the Claude Code platform, following Kent Beck's Test-Driven Development and Tidy First methodologies.

---

## 🎯 Core Development Principles

### TDD Cycle: Red → Green → Refactor
- ❌ **Red**: Write the simplest failing test first
- ✅ **Green**: Implement the minimum code needed to make tests pass
- ♻️ **Refactor**: Refactor only after tests are passing
- 🔄 **Repeat**: Continue cycle for new functionality

### Tidy First Approach
- 🏗️ **Structural Changes**: Rearranging code without changing behavior (renaming, extracting methods, moving code)
- 🚀 **Behavioral Changes**: Adding or modifying actual functionality
- ⚠️ **Never mix** structural and behavioral changes in the same commit
- ✨ **Always make** structural changes first when both are needed

---

## 🧪 1. Test-Driven Development Rules

### Writing Tests
- ✅ **One test at a time**: Write a single failing test that defines a small increment of functionality
- ✅ **Meaningful test names**: Use names that describe behavior (e.g., `testSumsTwoPositiveNumbers`)
- ✅ **Clear test failures**: Make test failures informative and specific
- ✅ **Minimal implementation**: Write just enough code to make the test pass - no more
- ✅ **Run all tests**: Always run all tests (except long-running tests) after each change

### Test Automation
- 🧪 **Run tests automatically after code changes**:
  - Tool: `Bash` → `tuist test --platform ios` --skip-ui-tests
  - If working on UI tests: `Bash` → `tuist test --platform ios`
  - Execution Point: `PostToolUse`
- 📈 **Generate test coverage reports**:
  - Tool: `Bash` → `tuist test`
  - Execution Point: `Stop`
- 🎯 **Validate tests pass before commits**:
  - All tests must pass before any commit
  - Tool: `Bash` → `tuist test --platform ios`

---

## 🛠 2. Code Style and Consistency

### Swift Standards
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

### File Organization
- ✅ **Standardize file structure and naming**:
  - All SwiftUI views must be named with a `View` suffix (e.g., `LoginView.swift`)
  - Models in `/Models`, views in `/Views`, helpers in `/Utils`
  - Test files parallel source structure in `/Tests`

---

## 💎 3. Code Quality Standards

### Beck's Quality Principles
- 🚫 **Eliminate duplication** ruthlessly
- 💡 **Express intent clearly** through naming and structure
- 🔗 **Make dependencies explicit**
- 📦 **Keep methods small** and focused on a single responsibility
- 🎯 **Minimize state** and side effects
- 🛠️ **Use the simplest solution** that could possibly work

### Refactoring Guidelines
- ♻️ **Refactor only when tests are passing** (in the "Green" phase)
- 📋 **Use established refactoring patterns** with their proper names
- 1️⃣ **Make one refactoring change at a time**
- ✅ **Run tests after each refactoring step**
- 🎯 **Prioritize refactorings** that remove duplication or improve clarity

---

## 📝 4. Commit Discipline

### Commit Requirements
Only commit when:
1. ✅ ALL tests are passing
2. ⚠️ ALL compiler/linter warnings have been resolved
3. 📦 The change represents a single logical unit of work
4. 📝 Commit messages clearly state whether the commit contains structural or behavioral changes

### Commit Best Practices
- 🔄 **Small, frequent commits** rather than large, infrequent ones
- 🏗️ **Separate commits** for structural vs behavioral changes
- 📋 **Clear commit messages** following format:
  - `[STRUCTURAL] Refactor: Extract method calculateTotal`
  - `[BEHAVIORAL] Feature: Add user authentication`
  - `[TEST] Test: Add unit tests for UserService`

---

## 🔍 5. Tooling and Project-Wide Operations

### Pre-Edit Operations
- 📖 **Read** source files before edits to preserve patterns
  - Tool: `Read`
  - Execution Point: `PreToolUse`
- 🔍 **Check existing patterns** before writing new components:
  - Tools: `Read`, `Grep`, `Glob` at `PreToolUse`

### Batch Operations
- 🔁 **Use `MultiEdit`** for batch updates during refactors
  - E.g., Rename `@State` properties project-wide
  - Tool: `MultiEdit`
- 🔎 **Use `Grep` or `Glob`** to:
  - Find unused code (`func`, `var`, `class` not referenced)
  - Detect deprecated API usage
  - Identify code duplication
  - Tool: `Grep`, `Glob`

### Build Validation
- 🏗 **Run `tuist generate` after files are added or removed**:
  - Ensures most recent project structure
  - Tool: `Bash` → `tuist generate`
  - Execution Point: `PostToolUse`
- 🏗 **Run `tuist build` after file updates**:
  - Ensures no build regressions
  - Tool: `Bash` → `tuist build --platform ios --skip-ui-tests`
  - If working on UI tests: `Bash` → `tuist test --platform ios`
  - Execution Point: `PostToolUse`

---

## 🧹 6. Documentation and Code Comments

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

## 🔐 7. Security and Safety Checks

- 🛑 **Validate file paths and avoid sensitive file writes**:
  - Execution Point: `PreToolUse`
  - Rule: Never overwrite `.env`, `Secrets.plist`, or `Info.plist` without confirmation
- 🚫 **Reject code with hardcoded credentials**:
  - Tool: `Grep`
  - Rule: Detect patterns like `let password =`, `API_KEY =`

---

## 🔄 8. Workflow Automation with Execution Points

| **Execution Point** | **Automated Rules** |
|---------------------|---------------------|
| `PreToolUse`        | Validate files, run security checks, load config, read existing patterns |
| `PostToolUse`       | Run linters, formatters, build system, run tests |
| `Stop`              | Run full test suite, summarize changes, generate coverage reports |
| `SessionStart`      | Load project settings and environment variables |
| `UserPromptSubmit`  | Enhance prompt with context and documentation |
| `SubagentStop`      | Merge subtask results and clean up |
| `Notification`      | Alert on critical errors, ask for permission |
| `PreCompact`        | Backup important context and user decisions |

---

## 🎯 9. TDD Workflow Example

When approaching a new feature:

1. **Write a simple failing test** for a small part of the feature
   ```swift
   func testUserCanLoginWithValidCredentials() {
       // Given
       let user = User(email: "test@example.com", password: "password123")
       let authService = AuthenticationService()
       
       // When
       let result = authService.login(user: user)
       
       // Then
       #expect(result.isSuccess == true)
   }
   ```

2. **Implement the bare minimum** to make it pass
   ```swift
   func login(user: User) -> Result<Bool, Error> {
       return .success(true)
   }
   ```

3. **Run tests** to confirm they pass (Green)
   - `tuist test --platform ios  --skip-ui-tests`
   - If working on UI tests: `tuist test --platform ios`
   
4. **Make any necessary structural changes** (Tidy First)
   - Extract methods, rename variables, reorganize code
   - Run tests after each change

5. **Commit structural changes separately**
   - `[STRUCTURAL] Refactor: Extract validation logic to separate method`

6. **Add another test** for the next small increment of functionality

7. **Repeat** until the feature is complete, committing behavioral changes separately

---

## 🌍 10. External Integration

- 🌐 **Use `WebSearch`** to:
  - Find Swift best practices and TDD examples
  - Investigate error messages
  - Research testing frameworks and patterns
  - Execution Point: `UserPromptSubmit`
- 📥 **Use `WebFetch`** to:
  - Retrieve remote documentation or JSON examples
  - Fetch external API schemas
  - Get latest testing best practices

---

## 💡 11. Developer Best Practices

### TDD Mindset
- 🧠 **Think test-first**: Before writing any production code, ask "What test would drive this?"
- 🎯 **Small steps**: Each test should drive a small, manageable change
- 🔄 **Continuous refactoring**: Keep code clean as you go, not as a separate phase
- 📊 **Measure progress**: Use test coverage as one metric of code completeness

### Code Review Checklist
- [ ] All tests pass
- [ ] No compiler warnings
- [ ] Code follows Swift conventions
- [ ] Duplication has been removed
- [ ] Intent is clear from naming
- [ ] Commits are properly separated (structural vs behavioral)
- [ ] Documentation is up to date
- [ ] No hardcoded values or credentials

### Development Practices
- 🪄 **Use `Task` for complex workflows**, such as:
  - Creating a new feature module with tests
  - Migrating from UIKit to SwiftUI with test coverage
  - Implementing a new API with full test suite
- ♻️ **Refactor regularly** using `MultiEdit` and `Glob`
- 🧪 **Maintain high test coverage** (aim for >80%)
- 📝 **Document why, not what** in comments

---

This document serves as the definitive guide for maintaining clean, testable, and maintainable SwiftUI code following TDD principles.