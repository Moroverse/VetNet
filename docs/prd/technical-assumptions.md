# Technical Assumptions

## Repository Structure
**Approach**: Monorepo structure optimized for iOS ecosystem with shared packages for cross-platform features

## Service Architecture
**CRITICAL DECISION**: Native iOS client with cloud-based backend services, designed for single-practice excellence with future multi-practice network expansion capability

## Testing Requirements
**CRITICAL DECISION**: Comprehensive testing strategy utilizing Swift Testing framework with Mockable package for service layer testing, ensuring reliability for mission-critical veterinary scheduling decisions

## iOS-Specific Technical Stack

**Core iOS Technologies**:
- **Language**: Swift 6.2+ with modern concurrency, structured concurrency, and @Observable state management
- **UI Framework**: SwiftUI with iOS 26 Liquid Glass design system implementation using glassEffect(), GlassEffectContainer, and interactive modifiers
- **Architecture Pattern**: MVVM optimized for SwiftUI data flow with clear separation of concerns and glass element organization

**iOS 26 Liquid Glass Integration**:
- **Primary Glass APIs**: glassEffect() modifier with shape and style parameters for core interface elements
- **Container Management**: GlassEffectContainer for grouping multiple glass elements ensuring consistent visual results
- **Interactive Elements**: interactive modifier enabling scaling, bouncing, and shimmering for custom scheduling controls
- **Morphing Effects**: glassEffectID modifier for fluid transitions between appointment states and scheduling views
- **Performance**: Metal Performance Shaders integration providing 40% GPU reduction and 39% faster rendering for complex interfaces

**Dependency Integration**:
- **Dependency Injection**: Factory (https://github.com/hmlongco/Factory) for clean architecture and testability
- **Form Management**: QuickForm (https://github.com/Moroverse/quick-form) for smart triage intake forms
- **State Management**: StateKit (https://github.com/Moroverse/state-kit) complementing @Observable for complex view states
- **Service Testing**: Mockable (https://github.com/Kolos65/Mockable) for comprehensive service layer testing
- **Navigation**: SwiftUIRouting (local package) for veterinary workflow-optimized navigation patterns

**Backend Integration**:
- **API Communication**: RESTful APIs with async/await patterns for seamless iOS 26 integration
- **Data Persistence**: SwiftData with custom DataStore protocol for real-time synchronization, compound uniqueness constraints via #Unique macro, and enhanced query performance with #Index
- **Authentication**: Apple Sign-In with practice-level access control, secure token management, and iOS 26 privacy enhancements

## Additional Technical Assumptions and Requests
**iOS 26 Platform Optimization**: All architecture decisions prioritize native iOS 26 performance including Metal Performance Shaders integration and automatic Xcode 26 rebuild optimizations

**Liquid Glass Design Implementation**: Application leverages research-validated performance improvements (40% GPU reduction, 39% faster rendering) while maintaining professional medical software accessibility standards

**Enhanced Accessibility Integration**: iOS 26 Accessibility Reader system-wide reading mode, improved VoiceOver with Live Recognition, and Braille Access support for professional veterinary practice compliance

**Cross-Platform Consistency**: Leveraging Apple's first unified design language across iOS 26, iPadOS 26, and macOS 26 for seamless veterinary workflow transitions between devices

**Real-time Performance**: SwiftData custom DataStore protocol enables veterinary-specific data synchronization with compound uniqueness constraints preventing appointment conflicts
