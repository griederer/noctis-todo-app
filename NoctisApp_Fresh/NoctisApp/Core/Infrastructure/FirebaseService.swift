import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseCrashlytics

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private init() {}
    
    func configure() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            Logger.shared.error("GoogleService-Info.plist not found")
            return
        }
        
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            Logger.shared.error("Failed to load Firebase options")
            return
        }
        
        FirebaseApp.configure(options: options)
        Logger.shared.info("Firebase configured successfully")
        
        // Enable analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // Configure Crashlytics
        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        #else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }
    
    var auth: Auth {
        return Auth.auth()
    }
    
    var firestore: Firestore {
        return Firestore.firestore()
    }
    
    var analytics: Analytics.Type {
        return Analytics.self
    }
    
    var crashlytics: Crashlytics {
        return Crashlytics.crashlytics()
    }
}