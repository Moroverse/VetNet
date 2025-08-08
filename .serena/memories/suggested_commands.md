# Essential VetNet Development Commands

## Project Setup & Building
```bash
# Install Tuist and dependencies (managed via mise)
mise install

# Generate Xcode project from Tuist configuration
tuist generate

# Build the main app target
tuist build VetNet

# Clean build artifacts
tuist clean
```

## Testing Commands
```bash
# Run all tests
tuist test VetNet

# Run tests with coverage
tuist test --coverage

# Run specific test target
tuist test VetNetTests

# Run UI tests (when implemented)
tuist test VetNetUITests

# Run SwiftUIRouting module tests
cd Modules/SwiftUIRouting && swift test
```

## Module Development (SwiftUIRouting)
```bash
# Build the custom routing module
cd Modules/SwiftUIRouting
swift build

# Generate documentation for module
swift package generate-documentation
```

## Code Quality Commands
```bash
# Run SwiftLint (after setup)
swiftlint

# Run SwiftFormat (after setup)
swiftformat .

# Note: Linting/formatting tools not currently installed in the project
```

## Development Environment
```bash
# Force local storage (disable CloudKit) for development
FORCE_LOCAL_STORAGE=1

# Enable mock data via feature flags (debug builds only)
# Access via shake gesture in DEBUG builds
```

## Git Commands (Standard)
```bash
git status
git add .
git commit -m "message"
git push
git pull
```

## System Commands (Darwin)
```bash
# List files
ls -la

# Find files
find . -name "*.swift"

# Search in files
grep -r "searchterm" .

# Better search with ripgrep (if available)
rg "searchterm"
```

## Documentation Access
The project has comprehensive documentation in:
- `docs/architecture/` - Technical implementation details
- `docs/prd/` - Product requirements and epics
- `CLAUDE.md` - Development guidance and session learnings