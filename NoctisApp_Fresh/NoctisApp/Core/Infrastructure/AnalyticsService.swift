import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        Logger.shared.info("Screen tracked: \(screenName)")
    }
    
    // MARK: - Todo Events
    func trackTodoCreated() {
        Analytics.logEvent("todo_created", parameters: [:])
    }
    
    func trackTodoCompleted() {
        Analytics.logEvent("todo_completed", parameters: [:])
    }
    
    func trackTodoDeleted() {
        Analytics.logEvent("todo_deleted", parameters: [:])
    }
    
    func trackTodoEdited() {
        Analytics.logEvent("todo_edited", parameters: [:])
    }
    
    func trackTodoPriorityChanged(priority: String) {
        Analytics.logEvent("todo_priority_changed", parameters: [
            "priority": priority
        ])
    }
    
    // MARK: - Authentication Events
    func trackSignIn(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    func trackSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    func trackSignOut() {
        Analytics.logEvent("sign_out", parameters: [:])
    }
    
    // MARK: - User Properties
    func setUserProperty(value: String?, property: String) {
        Analytics.setUserProperty(value, forName: property)
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }
    
    // MARK: - Custom Events
    func trackCustomEvent(name: String, parameters: [String: Any] = [:]) {
        Analytics.logEvent(name, parameters: parameters)
        Logger.shared.info("Custom event tracked: \(name)")
    }
    
    // MARK: - Crash Reporting
    func recordError(_ error: Error, additionalInfo: [String: Any] = [:]) {
        Crashlytics.crashlytics().record(error: error)
        
        for (key, value) in additionalInfo {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
        
        Logger.shared.error("Error recorded: \(error.localizedDescription)")
    }
    
    func setUserIdentifier(_ identifier: String) {
        Crashlytics.crashlytics().setUserID(identifier)
    }
    
    func logMessage(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}