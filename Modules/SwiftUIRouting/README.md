# SwiftUIRouting

A comprehensive, dependency-free Swift package for type-safe bidirectional routing in SwiftUI applications.

## Features

- 🔄 **Bidirectional Routing**: Result-aware navigation with immediate user feedback
- 🛡️ **Type Safety**: Compile-time validation for all routing operations  
- 📱 **Pure SwiftUI**: Zero external dependencies, uses only SwiftUI + Foundation
- ⚡ **Modern Patterns**: async/await, @Observable, Swift 6.0 concurrency
- ✅ **Production Ready**: Comprehensive testing, documentation, and examples

## Requirements

- iOS 17.0+, macOS 14.0+, watchOS 10.0+, tvOS 17.0+
- Swift 6.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SwiftUIRouting to your project through Xcode:

1. File → Add Package Dependencies
2. Enter package URL: `https://github.com/your-org/SwiftUIRouting`
3. Select version requirements

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/SwiftUIRouting", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your Result Types

```swift
import SwiftUIRouting

enum UserFormResult {
    case created(User)
    case updated(User)
    case cancelled
    case error(Error)
}

extension UserFormResult: RouteResult {
    typealias SuccessType = User
    typealias ErrorType = Error
    
    var isSuccess: Bool {
        switch self {
        case .created, .updated: true
        case .cancelled, .error: false
        }
    }
    
    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}
```

### 2. Create Your Router

```swift
enum UserFormMode: Identifiable {
    case create
    case edit(User.ID)
    
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let id): return "edit-\(id)"
        }
    }
}

@Observable
class UserRouter: BaseFormRouter<UserFormMode, UserFormResult> {
    
    // Async methods
    func createUser() async -> UserFormResult {
        return await presentForm(.create)
    }
    
    func editUser(_ id: User.ID) async -> UserFormResult {
        return await presentForm(.edit(id))
    }
    
    // Callback methods
    func createUser(onResult: @escaping (UserFormResult) -> Void) {
        presentForm(.create, onResult: onResult)
    }
    
    // Legacy methods (backward compatibility)
    func createUser() {
        presentForm(.create)
    }
}
```

### 3. Set Up Router Views

```swift
struct ContentView: View {
    @State private var userRouter = UserRouter()
    @State private var users: [User] = []
    
    var body: some View {
        FormRouterView(router: userRouter) {
            NavigationView {
                UserListView(users: users) { user in
                    Task {
                        let result = await userRouter.editUser(user.id)
                        handleUserResult(result)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add User") {
                            Task {
                                let result = await userRouter.createUser()
                                handleUserResult(result)
                            }
                        }
                    }
                }
            }
        } formContent: { mode in
            AnyView(UserFormView(mode: mode) { result in
                userRouter.handleResult(result)
            })
        }
    }
    
    private func handleUserResult(_ result: UserFormResult) {
        switch result {
        case .created(let user):
            users.append(user)
        case .updated(let user):
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index] = user
            }
        case .cancelled, .error:
            break
        }
    }
}
```

## Core Concepts

### Router Protocols

- **Router**: Base protocol for navigation and dismissal
- **FormRouting**: Protocol for form-based routing with result handling
- **AppRouting**: Protocol for app-level routing (alerts, overlays)

### Result Handling

- **RouteResult**: Protocol for type-safe result communication
- **FormOperationResult<T>**: Generic result type for CRUD operations
- **SimpleOperationResult**: Basic success/failure result type

### Router Views

- **FormRouterView**: Handles form modal presentations
- **AlertRouterView**: Manages alert presentations
- **OverlayRouterView**: Handles overlay presentations
- **NavigationRouterView**: Manages navigation stack

## Documentation

- [Getting Started Guide](Documentation/Guides/GettingStarted.md)
- [Async Routing Patterns](Documentation/Guides/AsyncRouting.md)
- [Result Handling](Documentation/Guides/ResultHandling.md)
- [Testing Guide](Documentation/Guides/Testing.md)
- [API Documentation](Documentation/API/)

## Example App

See the complete example application in the `Examples/SwiftUIRoutingExample` directory for comprehensive usage patterns.

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

SwiftUIRouting is available under the MIT license. See the LICENSE file for more info.