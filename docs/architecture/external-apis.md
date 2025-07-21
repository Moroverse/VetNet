# External APIs

## CloudKit Veterinary Data Synchronization
- **Purpose**: HIPAA-compliant cloud synchronization for veterinary practice data across iOS devices
- **Documentation**: Apple CloudKit Developer Documentation
- **Base URL**: Apple CloudKit services (automatic)
- **Authentication**: Apple Sign-In with practice-level access control
- **Rate Limits**: CloudKit standard quotas with veterinary data optimization

**Key Endpoints Used**:
- CloudKit automatic sync for SwiftData models
- Custom zones for practice-specific data isolation
- Subscription services for real-time appointment updates

**Integration Notes**: Leverages iOS 26 CloudKit improvements for enhanced synchronization performance and conflict resolution

## Apple Core ML Intelligence Services
- **Purpose**: On-device machine learning for scheduling optimization and case complexity assessment
- **Documentation**: Apple Core ML and Create ML Documentation
- **Integration Type**: Native iOS framework integration
- **Processing**: On-device inference for privacy and performance

**Key Capabilities**:
- Case complexity scoring based on symptom patterns
- Specialist matching optimization using historical data
- Appointment duration prediction for schedule optimization
