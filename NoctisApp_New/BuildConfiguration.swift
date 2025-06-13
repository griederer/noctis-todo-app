//
//  BuildConfiguration.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation

enum Environment {
    case debug
    case testing
    case production
    
    static var current: Environment {
        #if DEBUG
        if ProcessInfo.processInfo.environment["ENVIRONMENT"] == "TESTING" {
            return .testing
        }
        return .debug
        #else
        return .production
        #endif
    }
}

struct BuildConfiguration {
    
    // MARK: - Environment Detection
    
    static var environment: Environment {
        return Environment.current
    }
    
    static var isDebug: Bool {
        return environment == .debug
    }
    
    static var isTesting: Bool {
        return environment == .testing
    }
    
    static var isProduction: Bool {
        return environment == .production
    }
    
    // MARK: - Configuration Values
    
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.noctis.app"
    }
    
    static var displayName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Noctis"
    }
    
    // MARK: - Environment Variables
    
    static var firebaseEnvironment: String {
        return ProcessInfo.processInfo.environment["FIREBASE_ENVIRONMENT"] ?? "development"
    }
    
    static var apiBaseURL: String {
        return ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://noctis-todo-default-rtdb.firebaseio.com"
    }
    
    static var enableDebugLogging: Bool {
        let value = ProcessInfo.processInfo.environment["ENABLE_DEBUG_LOGGING"] ?? "NO"
        return value.uppercased() == "YES" || value.uppercased() == "TRUE"
    }
    
    static var disableAnalytics: Bool {
        let value = ProcessInfo.processInfo.environment["DISABLE_ANALYTICS"] ?? "NO"
        return value.uppercased() == "YES" || value.uppercased() == "TRUE"
    }
    
    static var disableCrashlytics: Bool {
        let value = ProcessInfo.processInfo.environment["DISABLE_CRASHLYTICS"] ?? "NO"
        return value.uppercased() == "YES" || value.uppercased() == "TRUE"
    }
    
    static var useMockData: Bool {
        let value = ProcessInfo.processInfo.environment["USE_MOCK_DATA"] ?? "NO"
        return value.uppercased() == "YES" || value.uppercased() == "TRUE"
    }
    
    // MARK: - Debug Information
    
    static var debugDescription: String {
        return """
        Build Configuration:
        - Environment: \(environment)
        - App Version: \(appVersion) (\(buildNumber))
        - Bundle ID: \(bundleIdentifier)
        - Firebase Environment: \(firebaseEnvironment)
        - Debug Logging: \(enableDebugLogging)
        - Analytics Disabled: \(disableAnalytics)
        - Crashlytics Disabled: \(disableCrashlytics)
        - Mock Data: \(useMockData)
        """
    }
    
    // MARK: - Configuration Validation
    
    static func validate() -> [String] {
        var issues: [String] = []
        
        // Check bundle identifier
        if bundleIdentifier.isEmpty {
            issues.append("Bundle identifier is empty")
        }
        
        // Check version numbers
        if appVersion.isEmpty {
            issues.append("App version is empty")
        }
        
        if buildNumber.isEmpty {
            issues.append("Build number is empty")
        }
        
        // Check Firebase configuration
        if firebaseEnvironment.isEmpty {
            issues.append("Firebase environment is not set")
        }
        
        // Check API URL
        if apiBaseURL.isEmpty {
            issues.append("API base URL is not set")
        } else if !apiBaseURL.hasPrefix("https://") {
            issues.append("API base URL should use HTTPS")
        }
        
        return issues
    }
    
    static var isValidConfiguration: Bool {
        return validate().isEmpty
    }
}

// MARK: - Debug Utilities

extension BuildConfiguration {
    
    static func printConfiguration() {
        guard enableDebugLogging else { return }
        print("🔧 \(debugDescription)")
    }
    
    static func printValidation() {
        let issues = validate()
        if issues.isEmpty {
            print("✅ Build configuration is valid")
        } else {
            print("❌ Build configuration issues:")
            issues.forEach { print("  - \($0)") }
        }
    }
}