# ``SwiftUIRouting``

A comprehensive routing solution for SwiftUI applications

## Overview

This module provides a complete set of tools for implementing type-safe,
bidirectional routing in SwiftUI applications with zero external dependencies.

## Key Features

- **Bidirectional Routing**: Result-aware navigation with immediate user feedback
- **Type Safety**: Compile-time validation for all routing operations
- **Pure SwiftUI**: Zero external dependencies, uses only SwiftUI + Foundation
- **Modern Patterns**: async/await, @Observable, Swift 6.0 concurrency
- **Production Ready**: Comprehensive testing, documentation, and examples

## Example Usage

```swift
import SwiftUIRouting

// Define your form modes
enum UserFormMode: Identifiable {
case create, edit(User.ID)
var id: String { /* implementation */ }
}

// Create a router
@Observable
class UserRouter: BaseFormRouter<UserFormMode, FormOperationResult<User>> {
func createUser() async -> FormOperationResult<User> {
return await presentForm(.create)
}
}

// Use in your views
struct ContentView: View {
@State private var userRouter = UserRouter()

var body: some View {
FormRouterView(router: userRouter) {
UserListView()
} formContent: { mode in
AnyView(UserFormView(mode: mode) { result in
userRouter.handleResult(result)
})
}
}
}
```

For more detailed documentation and examples, see the individual type documentation
and the comprehensive example application included with this package.

## Topics

### Core Protocols

- ``Router``
- ``FormRouting``
- ``AppRouting``
- ``RouteResult``

### Base Implementations

- ``BaseFormRouter``
- ``BaseAppRouter``

### Router Views

- ``FormRouterView``
- ``AlertRouterView``
- ``OverlayRouterView``
- ``NavigationRouterView``
### Result Types

- ``FormOperationResult``
- ``SimpleOperationResult``
- ``AppAlert``
- ``AppAlertAction``
