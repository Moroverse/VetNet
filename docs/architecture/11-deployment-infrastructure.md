# Deployment Infrastructure and CI/CD

## Overview

This document details the deployment infrastructure and CI/CD pipeline architecture for VetNet, emphasizing iOS 26 optimization, enterprise deployment strategies, and automated quality assurance processes for veterinary practice software.

Related documents: [02-tech-stack.md](02-tech-stack.md) | [08-security-performance.md](08-security-performance.md) | [09-testing-strategy.md](09-testing-strategy.md)

## iOS 26 Deployment Architecture

### Deployment Strategy Overview

**Primary Strategy**: **Native iOS App Store + Enterprise Distribution**

The deployment architecture supports both premium veterinary market distribution and large-scale enterprise deployment for veterinary practice networks.

### App Store Distribution

**Target Market**: Premium veterinary practices through Apple Business Manager
- **Pricing Model**: Subscription-based leveraging StoreKit 2
- **Geographic Distribution**: Worldwide availability with regional HIPAA compliance
- **Device Targeting**: iPadOS 26+ (primary), iOS 26+ (secondary), macOS 26+ (administrative)

**App Store Connect Configuration**:
```yaml
# App Store Metadata
app_identifier: com.moroverse.VetNet
primary_category: Medical
secondary_category: Business
age_rating: 4+
pricing_model: subscription

# iOS 26 Specific Features
required_device_capabilities:
  - metal-performance-shaders-tier3
  - liquid-glass-ui
  - biometric-authentication
  
minimum_os_versions:
  ios: "17.0"
  ipados: "17.0" 
  macos: "14.0"

target_os_versions:
  ios: "26.0"
  ipados: "26.0"
  macos: "26.0"
```

### Enterprise Deployment

**Target Enterprises**: Large veterinary practice networks and hospital systems

**Apple Business Manager Integration**:
```swift
// Enterprise configuration management
struct EnterpriseConfiguration {
    let practiceNetworkId: UUID
    let deploymentProfile: DeploymentProfile
    let mdmConfiguration: MDMConfiguration
    let customBranding: BrandingConfiguration
    
    enum DeploymentProfile {
        case smallPractice(locations: Int)
        case mediumNetwork(locations: Int)
        case largeHospitalSystem(locations: Int, specialists: Int)
        case enterpriseChain(locations: Int, regions: Int)
    }
}

// MDM Integration for enterprise deployment
final class MDMConfigurationManager {
    func deployToManagedDevices(
        configuration: EnterpriseConfiguration
    ) async throws -> DeploymentResult {
        // Configure practice-specific settings
        let practiceSettings = PracticeSettings(
            networkId: configuration.practiceNetworkId,
            operatingHours: configuration.deploymentProfile.defaultOperatingHours,
            specialties: configuration.deploymentProfile.availableSpecialties
        )
        
        // Deploy via Apple Business Manager
        return try await deployViaABM(
            settings: practiceSettings,
            mdmConfig: configuration.mdmConfiguration
        )
    }
}
```

## CI/CD Pipeline Architecture

### Xcode Cloud Integration

The CI/CD pipeline leverages Xcode Cloud for iOS 26-optimized build and testing processes.

```yaml
# ci_workflows/production.yml
name: VetNet Production Pipeline
description: Production deployment pipeline with iOS 26 optimization

start_conditions:
  - branch_changes:
      include: [main]
  - tag:
      include: [v*]

environment:
  xcode: 26.0
  macos: 15.0
  
workflows:
  build_and_test:
    environment: 
      ios: 26.0
      ipados: 26.0
    
    actions:
      - name: Build VetNet
        action: build
        scheme: VetNet
        destination: generic/platform=iOS
      
      - name: Run Unit Tests
        action: test
        scheme: VetNet
        destination: platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)
        test_plan: UnitTests
      
      - name: Run Integration Tests  
        action: test
        scheme: VetNet
        destination: platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)
        test_plan: IntegrationTests
      
      - name: Performance Testing
        action: test
        scheme: VetNet
        destination: platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation) 
        test_plan: PerformanceTests
      
      - name: Accessibility Testing
        action: test
        scheme: VetNet
        destination: platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)
        test_plan: AccessibilityTests
      
      - name: Security Scanning
        action: analyze
        scheme: VetNet
        
      - name: Archive for Distribution
        action: archive
        scheme: VetNet
        destination: generic/platform=iOS
```

### GitHub Actions Secondary Pipeline

Complementary GitHub Actions for additional validations and deployment tasks.

```yaml\n# .github/workflows/ci.yml\nname: VetNet CI/CD Pipeline\n\non:\n  push:\n    branches: [ main, develop ]\n  pull_request:\n    branches: [ main ]\n  release:\n    types: [ published ]\n\njobs:\n  validate:\n    runs-on: macos-14\n    steps:\n    - uses: actions/checkout@v4\n    \n    - name: Setup Xcode\n      run: sudo xcode-select -s /Applications/Xcode_26.0.app/Contents/Developer\n    \n    - name: Cache Tuist Dependencies\n      uses: actions/cache@v3\n      with:\n        path: ~/.tuist\n        key: ${{ runner.os }}-tuist-${{ hashFiles('**/Project.swift') }}\n    \n    - name: Install mise and dependencies\n      run: |\n        curl https://mise.run | sh\n        echo \"$HOME/.local/bin\" >> $GITHUB_PATH\n        mise install\n    \n    - name: Generate Xcode Project\n      run: tuist generate\n    \n    - name: Validate iOS 26 Compliance\n      run: |\n        # Check for iOS 26 specific APIs\n        grep -r \"@Observable\" App/Sources/ || exit 1\n        grep -r \"glassEffect\" App/Sources/ || exit 1\n        grep -r \"TaskGroup\" App/Sources/ || exit 1\n    \n    - name: SwiftLint\n      run: swiftlint --strict\n    \n    - name: Security Audit\n      run: |\n        # Check for hardcoded secrets\n        git secrets --scan\n        # Check for security vulnerabilities\n        semgrep --config=security .\n        \n  test_modules:\n    runs-on: macos-14\n    needs: validate\n    strategy:\n      matrix:\n        module: [Scheduling, Triage, PatientRecords, SpecialistManagement]\n    steps:\n    - uses: actions/checkout@v4\n    \n    - name: Test Module ${{ matrix.module }}\n      run: |\n        cd Features/${{ matrix.module }}\n        swift test --enable-code-coverage\n        xcrun llvm-cov export .build/debug/${{ matrix.module }}PackageTests.xctest/Contents/MacOS/${{ matrix.module }}PackageTests -format=\"lcov\" > coverage.lcov\n    \n    - name: Upload Coverage\n      uses: codecov/codecov-action@v3\n      with:\n        files: Features/${{ matrix.module }}/coverage.lcov\n        flags: ${{ matrix.module }}\n        \n  integration_tests:\n    runs-on: macos-14\n    needs: test_modules\n    steps:\n    - uses: actions/checkout@v4\n    \n    - name: Run Integration Tests\n      run: |\n        tuist generate\n        xcodebuild test \\\n          -scheme VetNet \\\n          -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=18.0' \\\n          -testPlan IntegrationTests \\\n          -resultBundlePath IntegrationTestResults.xcresult\n    \n    - name: Parse Test Results\n      run: |\n        xcrun xcresulttool get --format json --path IntegrationTestResults.xcresult > test_results.json\n        python3 scripts/parse_test_results.py test_results.json\n        \n  performance_validation:\n    runs-on: macos-14\n    needs: integration_tests\n    steps:\n    - uses: actions/checkout@v4\n    \n    - name: Performance Benchmarking\n      run: |\n        tuist generate\n        xcodebuild test \\\n          -scheme VetNet \\\n          -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=18.0' \\\n          -testPlan PerformanceTests \\\n          -resultBundlePath PerformanceResults.xcresult\n    \n    - name: Validate Performance Metrics\n      run: |\n        python3 scripts/validate_performance.py PerformanceResults.xcresult\n        # Ensure scheduling optimization completes within 1 second\n        # Validate memory usage stays below thresholds\n        # Check for performance regressions\n        \n  deploy_testflight:\n    runs-on: macos-14\n    needs: [integration_tests, performance_validation]\n    if: github.ref == 'refs/heads/main'\n    steps:\n    - uses: actions/checkout@v4\n    \n    - name: Deploy to TestFlight\n      env:\n        ASC_API_KEY_ID: ${{ secrets.ASC_API_KEY_ID }}\n        ASC_API_ISSUER_ID: ${{ secrets.ASC_API_ISSUER_ID }}\n        ASC_API_KEY: ${{ secrets.ASC_API_KEY }}\n      run: |\n        tuist generate\n        xcodebuild archive \\\n          -scheme VetNet \\\n          -destination generic/platform=iOS \\\n          -archivePath VetNet.xcarchive\n        \n        xcodebuild -exportArchive \\\n          -archivePath VetNet.xcarchive \\\n          -exportPath . \\\n          -exportOptionsPlist ExportOptions.plist\n        \n        xcrun altool --upload-app \\\n          --type ios \\\n          --file VetNet.ipa \\\n          --apiKey $ASC_API_KEY_ID \\\n          --apiIssuer $ASC_API_ISSUER_ID\n```\n\n## Environment Configuration\n\n### Development Environment Setup\n\n```bash\n#!/bin/bash\n# scripts/setup_dev_environment.sh\n\necho \"Setting up VetNet development environment...\"\n\n# Install mise for version management\nif ! command -v mise &> /dev/null; then\n    curl https://mise.run | sh\nfi\n\n# Install development tools\nmise install\n\n# Verify Xcode version\nif ! xcode-select -p | grep -q \"Xcode_26\"; then\n    echo \"Warning: Xcode 26 is required for iOS 26 development\"\n    echo \"Please install Xcode 26 and run: sudo xcode-select -s /Applications/Xcode_26.0.app/Contents/Developer\"\nfi\n\n# Generate Xcode project\ntuist generate\n\n# Setup git hooks\ncp scripts/pre-commit .git/hooks/pre-commit\nchmod +x .git/hooks/pre-commit\n\n# Install SwiftLint\nif ! command -v swiftlint &> /dev/null; then\n    brew install swiftlint\nfi\n\n# Setup CloudKit development environment\necho \"Setting up CloudKit development database...\"\npython3 scripts/setup_cloudkit_dev.py\n\necho \"Development environment setup complete!\"\necho \"Run 'tuist generate' to regenerate project files after changes.\"\n```\n\n### Production Environment Configuration\n\n```yaml\n# configs/production.yml\nenvironment: production\n\napp_configuration:\n  bundle_id: com.moroverse.VetNet\n  version_strategy: semantic\n  build_number_strategy: timestamp\n\ncloudkit:\n  environment: production\n  database: private\n  zones:\n    - PracticeData\n    - SharedConfiguration\n  subscriptions:\n    - AppointmentUpdates\n    - PatientRecordChanges\n    - EmergencyAlerts\n\nperformance:\n  metal_performance_shaders: enabled\n  liquid_glass_optimization: enabled\n  background_processing: enabled\n  \nsecurity:\n  data_encryption: aes_256_gcm\n  hipaa_compliance: strict\n  audit_logging: comprehensive\n  biometric_authentication: required\n  \naccessibility:\n  voiceover: enhanced\n  dynamic_type: full_support\n  accessibility_reader: enabled\n  medical_terminology: custom_pronunciations\n\nmonitoring:\n  crash_reporting: enabled\n  performance_monitoring: enabled\n  user_analytics: privacy_compliant\n  hipaa_audit_trail: enabled\n```\n\n### Staging Environment\n\n```yaml\n# configs/staging.yml\nenvironment: staging\n\ninherits_from: production\n\noverrides:\n  cloudkit:\n    environment: development\n  \n  security:\n    audit_logging: verbose  # More detailed logging for testing\n  \n  monitoring:\n    debug_logging: enabled\n    test_data_generation: enabled\n    \n  features:\n    feature_flags: all_enabled  # Test all features in staging\n    experimental_features: enabled\n```\n\n## Configuration Management\n\n### Practice-Specific Configuration\n\nUsing iOS 26's Configuration framework for practice-specific settings.\n\n```swift\n// App/Configuration/PracticeConfiguration.swift\nimport Configuration\n\nstruct PracticeConfiguration {\n    @ConfigurationValue(\"practice.id\")\n    var practiceId: UUID\n    \n    @ConfigurationValue(\"practice.name\")\n    var practiceName: String = \"Veterinary Practice\"\n    \n    @ConfigurationValue(\"practice.timezone\")\n    var timezone: TimeZone = TimeZone.current\n    \n    @ConfigurationValue(\"practice.operating_hours\")\n    var operatingHours: OperatingSchedule = .standard\n    \n    @ConfigurationValue(\"features.ai_scheduling\")\n    var aiSchedulingEnabled: Bool = true\n    \n    @ConfigurationValue(\"features.emergency_fast_track\")\n    var emergencyFastTrackEnabled: Bool = true\n    \n    @ConfigurationValue(\"ui.glass_effects\")\n    var liquidGlassEnabled: Bool = true\n    \n    @ConfigurationValue(\"compliance.hipaa_mode\")\n    var hipaaComplianceMode: HIPAAMode = .strict\n}\n\n// Dynamic configuration updates via CloudKit\nfinal class ConfigurationManager: ObservableObject {\n    @Published var currentConfiguration = PracticeConfiguration()\n    \n    private let cloudKitService: CloudKitConfigurationService\n    \n    func updateConfiguration() async {\n        do {\n            let remoteConfig = try await cloudKitService.fetchConfiguration()\n            await MainActor.run {\n                self.currentConfiguration = remoteConfig\n            }\n        } catch {\n            logger.error(\"Failed to update configuration: \\(error)\")\n        }\n    }\n}\n```\n\n### Feature Flag Management\n\n```swift\n// App/FeatureFlags/VeterinaryFeatureFlags.swift\nimport Configuration\n\nstruct VeterinaryFeatureFlags {\n    @FeatureFlag(\"ai_powered_scheduling\")\n    static var aiPoweredScheduling: Bool = false\n    \n    @FeatureFlag(\"metal_performance_optimization\")\n    static var metalOptimization: Bool = true\n    \n    @FeatureFlag(\"advanced_triage_protocols\")\n    static var advancedTriageProtocols: Bool = false\n    \n    @FeatureFlag(\"enterprise_analytics\")\n    static var enterpriseAnalytics: Bool = false\n    \n    @FeatureFlag(\"experimental_ui\")\n    static var experimentalUI: Bool = false\n}\n\n// Feature flag configuration per environment\nfinal class FeatureFlagManager {\n    static let shared = FeatureFlagManager()\n    \n    private let environment: AppEnvironment\n    \n    init(environment: AppEnvironment = .current) {\n        self.environment = environment\n        configureFeatureFlags()\n    }\n    \n    private func configureFeatureFlags() {\n        switch environment {\n        case .development:\n            VeterinaryFeatureFlags.aiPoweredScheduling = true\n            VeterinaryFeatureFlags.advancedTriageProtocols = true\n            VeterinaryFeatureFlags.experimentalUI = true\n            \n        case .staging:\n            VeterinaryFeatureFlags.aiPoweredScheduling = true\n            VeterinaryFeatureFlags.advancedTriageProtocols = true\n            VeterinaryFeatureFlags.experimentalUI = false\n            \n        case .production:\n            VeterinaryFeatureFlags.aiPoweredScheduling = false // Gradual rollout\n            VeterinaryFeatureFlags.advancedTriageProtocols = false\n            VeterinaryFeatureFlags.experimentalUI = false\n        }\n    }\n}\n```\n\n## Deployment Scripts and Automation\n\n### Automated Deployment Script\n\n```python\n#!/usr/bin/env python3\n# scripts/deploy.py\n\nimport subprocess\nimport sys\nimport json\nfrom pathlib import Path\n\nclass VetNetDeployer:\n    def __init__(self, environment: str):\n        self.environment = environment\n        self.config = self.load_config()\n        \n    def load_config(self):\n        config_path = Path(f\"configs/{self.environment}.yml\")\n        with open(config_path) as f:\n            return yaml.safe_load(f)\n    \n    def validate_environment(self):\n        \"\"\"Validate the deployment environment meets requirements\"\"\"\n        print(f\"Validating {self.environment} environment...\")\n        \n        # Check Xcode version\n        result = subprocess.run(\n            [\"xcodebuild\", \"-version\"],\n            capture_output=True,\n            text=True\n        )\n        \n        if \"Xcode 26\" not in result.stdout:\n            raise RuntimeError(\"Xcode 26 is required for iOS 26 deployment\")\n        \n        # Check iOS 26 SDK availability\n        result = subprocess.run(\n            [\"xcrun\", \"--sdk\", \"iphoneos\", \"--show-sdk-version\"],\n            capture_output=True,\n            text=True\n        )\n        \n        sdk_version = float(result.stdout.strip())\n        if sdk_version < 26.0:\n            raise RuntimeError(f\"iOS 26 SDK required, found {sdk_version}\")\n        \n        print(\"✅ Environment validation passed\")\n    \n    def run_tests(self):\n        \"\"\"Run comprehensive test suite before deployment\"\"\"\n        print(\"Running test suite...\")\n        \n        test_plans = [\n            \"UnitTests\",\n            \"IntegrationTests\", \n            \"PerformanceTests\",\n            \"AccessibilityTests\",\n            \"SecurityTests\"\n        ]\n        \n        for test_plan in test_plans:\n            print(f\"Running {test_plan}...\")\n            result = subprocess.run([\n                \"xcodebuild\", \"test\",\n                \"-scheme\", \"VetNet\",\n                \"-destination\", \"platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation),OS=18.0\",\n                \"-testPlan\", test_plan\n            ])\n            \n            if result.returncode != 0:\n                raise RuntimeError(f\"{test_plan} failed\")\n        \n        print(\"✅ All tests passed\")\n    \n    def build_and_archive(self):\n        \"\"\"Build and archive the application\"\"\"\n        print(\"Building and archiving application...\")\n        \n        # Generate project with Tuist\n        subprocess.run([\"tuist\", \"generate\"], check=True)\n        \n        # Archive for iOS\n        subprocess.run([\n            \"xcodebuild\", \"archive\",\n            \"-scheme\", \"VetNet\",\n            \"-destination\", \"generic/platform=iOS\",\n            \"-archivePath\", \"VetNet.xcarchive\",\n            \"CODE_SIGN_IDENTITY=Apple Distribution\",\n            f\"PROVISIONING_PROFILE_SPECIFIER={self.config['provisioning_profile']}\"\n        ], check=True)\n        \n        print(\"✅ Archive created successfully\")\n    \n    def export_ipa(self):\n        \"\"\"Export IPA for distribution\"\"\"\n        print(\"Exporting IPA...\")\n        \n        export_options = {\n            \"method\": \"app-store\" if self.environment == \"production\" else \"development\",\n            \"teamID\": self.config[\"team_id\"],\n            \"provisioningProfiles\": {\n                self.config[\"bundle_id\"]: self.config[\"provisioning_profile\"]\n            },\n            \"uploadBitcode\": False,\n            \"uploadSymbols\": True\n        }\n        \n        with open(\"ExportOptions.plist\", \"w\") as f:\n            plistlib.dump(export_options, f)\n        \n        subprocess.run([\n            \"xcodebuild\", \"-exportArchive\",\n            \"-archivePath\", \"VetNet.xcarchive\",\n            \"-exportPath\", \".\",\n            \"-exportOptionsPlist\", \"ExportOptions.plist\"\n        ], check=True)\n        \n        print(\"✅ IPA exported successfully\")\n    \n    def deploy_to_app_store(self):\n        \"\"\"Deploy to App Store Connect\"\"\"\n        if self.environment != \"production\":\n            print(\"Deploying to TestFlight...\")\n        else:\n            print(\"Deploying to App Store...\")\n        \n        subprocess.run([\n            \"xcrun\", \"altool\", \"--upload-app\",\n            \"--type\", \"ios\",\n            \"--file\", \"VetNet.ipa\",\n            \"--apiKey\", self.config[\"api_key_id\"],\n            \"--apiIssuer\", self.config[\"api_issuer_id\"]\n        ], check=True)\n        \n        print(\"✅ Deployment successful\")\n    \n    def deploy(self):\n        \"\"\"Execute complete deployment pipeline\"\"\"\n        try:\n            self.validate_environment()\n            self.run_tests()\n            self.build_and_archive()\n            self.export_ipa()\n            \n            if self.environment in [\"staging\", \"production\"]:\n                self.deploy_to_app_store()\n            \n            print(f\"🎉 Deployment to {self.environment} completed successfully!\")\n            \n        except Exception as e:\n            print(f\"❌ Deployment failed: {e}\")\n            sys.exit(1)\n\nif __name__ == \"__main__\":\n    if len(sys.argv) != 2:\n        print(\"Usage: python3 deploy.py <environment>\")\n        print(\"Environments: development, staging, production\")\n        sys.exit(1)\n    \n    environment = sys.argv[1]\n    deployer = VetNetDeployer(environment)\n    deployer.deploy()\n```\n\n## Monitoring and Observability\n\n### Application Monitoring Setup\n\n```swift\n// App/Monitoring/ApplicationMonitoring.swift\nimport OSLog\nimport MetricKit\n\nfinal class ApplicationMonitoring {\n    static let shared = ApplicationMonitoring()\n    \n    private let logger = Logger(\n        subsystem: Bundle.main.bundleIdentifier!,\n        category: \"VetNetMonitoring\"\n    )\n    \n    private init() {\n        setupCrashReporting()\n        setupPerformanceMonitoring()\n        setupHIPAAAuditLogging()\n    }\n    \n    private func setupCrashReporting() {\n        // Configure crash reporting (privacy-compliant)\n        CrashReporter.configure(\n            apiKey: Configuration.crashReportingKey,\n            hipaaCompliant: true,\n            excludePHI: true\n        )\n    }\n    \n    private func setupPerformanceMonitoring() {\n        // MetricKit for performance monitoring\n        MXMetricManager.shared.add(self)\n    }\n    \n    private func setupHIPAAAuditLogging() {\n        // Setup HIPAA-compliant audit logging\n        AuditLogger.configure(\n            practiceId: Configuration.practiceId,\n            environment: Configuration.environment,\n            encryptionEnabled: true\n        )\n    }\n}\n\nextension ApplicationMonitoring: MXMetricManagerSubscriber {\n    func didReceive(_ payloads: [MXMetricPayload]) {\n        for payload in payloads {\n            // Process performance metrics\n            if let appLaunchMetrics = payload.applicationLaunchMetrics {\n                logger.info(\"App launch time: \\(appLaunchMetrics.histogrammedTimeToFirstDrawKey)\")\n            }\n            \n            if let memoryMetrics = payload.memoryMetrics {\n                logger.info(\"Peak memory usage: \\(memoryMetrics.peakMemoryUsage)\")\n            }\n            \n            // Alert on performance degradation\n            validatePerformanceMetrics(payload)\n        }\n    }\n    \n    private func validatePerformanceMetrics(_ payload: MXMetricPayload) {\n        // Check for performance regressions\n        if let cpuMetrics = payload.cpuMetrics,\n           cpuMetrics.cumulativeCPUTime > acceptableThresholds.maxCPUTime {\n            logger.error(\"High CPU usage detected: \\(cpuMetrics.cumulativeCPUTime)\")\n            AlertManager.shared.sendPerformanceAlert(.highCPUUsage)\n        }\n    }\n}\n```\n\n## Rollback and Recovery Procedures\n\n### Automated Rollback System\n\n```swift\n// Infrastructure/Deployment/RollbackManager.swift\nfinal class RollbackManager {\n    static let shared = RollbackManager()\n    \n    func initiateEmergencyRollback(reason: RollbackReason) async {\n        logger.critical(\"Initiating emergency rollback: \\(reason)\")\n        \n        do {\n            // 1. Disable new feature flags immediately\n            await disableRiskyFeatures()\n            \n            // 2. Revert to last known good configuration\n            let lastGoodConfig = try await fetchLastKnownGoodConfiguration()\n            try await applyConfiguration(lastGoodConfig)\n            \n            // 3. Clear problematic caches\n            await clearApplicationCaches()\n            \n            // 4. Notify monitoring systems\n            await NotificationManager.sendCriticalAlert(\n                message: \"Emergency rollback completed\",\n                reason: reason\n            )\n            \n            logger.info(\"Emergency rollback completed successfully\")\n            \n        } catch {\n            logger.fault(\"Emergency rollback failed: \\(error)\")\n            // Escalate to manual intervention\n            await escalateToManualIntervention(error)\n        }\n    }\n}\n\nenum RollbackReason {\n    case criticalBug\n    case performanceDegradation\n    case securityIncident\n    case dataCorruption\n    case userReportedIssues\n}\n```\n\n## Related Documentation\n\n- **[02-tech-stack.md](02-tech-stack.md)**: Technology stack and deployment requirements\n- **[08-security-performance.md](08-security-performance.md)**: Security considerations for production deployment\n- **[09-testing-strategy.md](09-testing-strategy.md)**: Testing requirements in CI/CD pipeline\n- **[07-ios26-specifications.md](07-ios26-specifications.md)**: iOS 26 specific deployment considerations