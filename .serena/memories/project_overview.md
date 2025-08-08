# VetNet Project Overview

## Project Purpose
VetNet is a native iOS 26 veterinary practice intelligence application built for veterinary practices. The app provides:
- Patient management and profiles
- Appointment scheduling with AI-powered algorithms  
- Veterinary workflow optimization
- HIPAA-compliant data synchronization via CloudKit

## Technology Stack
- **Language**: Swift 6.2+ with structured concurrency patterns
- **UI Framework**: SwiftUI with iOS 26 Liquid Glass design system
- **Architecture**: MVVM + @Observable for optimal SwiftUI integration
- **Navigation**: Custom SwiftUIRouting module (bidirectional, type-safe routing)
- **Data**: SwiftData with CloudKit for HIPAA-compliant synchronization
- **Testing**: Swift Testing + Mockable + ViewInspector + XCTest for comprehensive coverage
- **Dependency Injection**: FactoryKit for clean, testable service layer
- **Project Management**: Tuist 4.55.6 (managed via mise)
- **Formatting**: FormatStyle API for consistent, locale-aware formatting
- **Measurements**: Type-safe Measurement API for veterinary calculations

## Target Platforms
- iOS 26.0+ (main application)
- iOS 17.0+ (SwiftUIRouting module)
- iPad, iPhone, Mac (multi-platform support)
- Bundle ID: `com.moroverse.VetNet`

## Key Features
- Custom SwiftUIRouting module for veterinary-specific navigation
- Liquid Glass UI implementation with morphing animations
- CloudKit synchronization with fallback to local storage
- Feature flag system for development configuration
- Sample data service for development and testing
- Comprehensive UI testing infrastructure (in development)