import Foundation

enum AppEnvironment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
}

class AppEnvironmentManager {
    static let shared = AppEnvironmentManager()
    
    private init() {}
    
    var current: AppEnvironment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
    
    var isDebug: Bool {
        return current == .development
    }
    
    var isProduction: Bool {
        return current == .production
    }
    
    // MARK: - Firebase Configuration
    var firebaseProjectId: String {
        switch current {
        case .development:
            return "noctis-todo-dev"
        case .staging:
            return "noctis-todo-staging"
        case .production:
            return "noctis-todo"
        }
    }
    
    // MARK: - API Configuration
    var apiBaseURL: String {
        switch current {
        case .development:
            return "https://api-dev.noctis.app"
        case .staging:
            return "https://api-staging.noctis.app"
        case .production:
            return "https://api.noctis.app"
        }
    }
    
    // MARK: - Feature Flags
    var enableAnalytics: Bool {
        switch current {
        case .development:
            return false
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    var enableCrashReporting: Bool {
        switch current {
        case .development:
            return false
        case .staging:
            return true
        case .production:
            return true
        }
    }
    
    var enableDetailedLogging: Bool {
        return current == .development
    }
    
    // MARK: - App Configuration
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.noctis.app"
    }
    
    // MARK: - Debug Information
    func printEnvironmentInfo() {
        Logger.shared.info("Environment: \(current.displayName)")
        Logger.shared.info("App Version: \(appVersion)")
        Logger.shared.info("Build Number: \(buildNumber)")
        Logger.shared.info("Bundle ID: \(bundleIdentifier)")
        Logger.shared.info("Firebase Project: \(firebaseProjectId)")
        Logger.shared.info("Analytics Enabled: \(enableAnalytics)")
        Logger.shared.info("Crash Reporting Enabled: \(enableCrashReporting)")
    }
}