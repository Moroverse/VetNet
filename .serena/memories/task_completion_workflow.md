# Task Completion Workflow for VetNet

## Standard Development Workflow

### 1. Before Starting
- Run `tuist generate` to ensure Xcode project is up-to-date
- Verify you're on the correct git branch
- Check current build status

### 2. During Development
- Follow established naming conventions and architecture patterns
- Add accessibility identifiers for any new UI components
- Write tests alongside implementation (ViewInspector for UI, Swift Testing for logic)
- Use FactoryKit for dependency injection
- Follow Clean Architecture principles with proper layer separation

### 3. Task Completion Checklist

#### Code Quality
- [ ] **Build Successfully**: `tuist build VetNet`
- [ ] **Tests Pass**: `tuist test VetNet`  
- [ ] **Module Tests Pass**: `cd Modules/SwiftUIRouting && swift test` (if module changes)
- [ ] **Code Format**: Apply SwiftFormat if available
- [ ] **Code Lint**: Apply SwiftLint if available

*Note: SwiftLint and SwiftFormat are configured but tools may need to be installed*

#### Architecture Compliance
- [ ] **Layer Separation**: Domain models pure, SwiftData in Infrastructure
- [ ] **Naming Conventions**: Follow established patterns for all new code
- [ ] **Dependency Injection**: Use FactoryKit patterns correctly
- [ ] **Accessibility**: All UI components have proper identifiers and labels
- [ ] **Concurrency**: Use async/await and structured concurrency patterns

#### Documentation
- [ ] **Update CLAUDE.md**: Add any new learnings to Session Learnings section
- [ ] **Architecture Changes**: Update relevant docs/ files if architecture modified
- [ ] **API Documentation**: Add SwiftDoc comments for public interfaces

#### Testing
- [ ] **Unit Tests**: Cover new business logic and services
- [ ] **UI Tests**: Add ViewInspector tests for new components
- [ ] **Integration Tests**: Verify feature works end-to-end
- [ ] **Mock Implementations**: Provide mocks for new services in Infrastructure/Mocks/

### 4. Before Committing
- [ ] **Clean Build**: `tuist clean && tuist generate && tuist build VetNet`
- [ ] **All Tests**: `tuist test --coverage`
- [ ] **No Debugging Code**: Remove console logs, force unwraps, test data
- [ ] **Feature Flags**: Ensure production-safe defaults

### 5. Post-Completion
- [ ] **Update Documentation**: Record any architectural decisions or patterns discovered
- [ ] **Session Learnings**: Document insights in CLAUDE.md for future reference
- [ ] **Clean Up**: Remove any temporary files or debugging artifacts

## Emergency Rollback Commands
```bash
# If build is broken
tuist clean
tuist generate
tuist build VetNet

# If tests are failing
tuist test VetNet --verbose

# If module is broken  
cd Modules/SwiftUIRouting
swift clean
swift build
swift test
```

## Quality Gates
- **No warnings or errors** in Xcode build
- **All tests passing** (unit, integration, UI where applicable)
- **Code follows** established architecture patterns
- **Accessibility requirements** met for any UI changes
- **Documentation updated** for significant changes

## Tools Status
- **Tuist**: ✅ Configured and working
- **Swift Testing**: ✅ Available
- **ViewInspector**: ✅ Available for UI testing
- **Mockable**: ✅ Available for service mocking
- **SwiftLint**: ⚠️ Configured but may need installation
- **SwiftFormat**: ⚠️ Configured but may need installation

*If linting/formatting tools are not available, focus on following the established code patterns manually*