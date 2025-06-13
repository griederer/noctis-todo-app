import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import SwiftUI

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user?.toUserModel()
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    AnalyticsService.shared.setUserId(user.uid)
                    AnalyticsService.shared.setUserIdentifier(user.uid)
                    Logger.shared.authInfo("User authenticated: \(user.uid)")
                } else {
                    AnalyticsService.shared.setUserId(nil)
                    Logger.shared.authInfo("User signed out")
                }
            }
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            setError("Unable to find root view controller")
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            setError("Unable to get Firebase client ID")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        setLoading(true)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Google Sign-In failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.setError("Failed to get Google user credentials")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)
                
                self?.signInWithCredential(credential, method: "google")
            }
        }
    }
    
    // MARK: - Email Sign In
    func signInWithEmail(_ email: String, password: String) {
        setLoading(true)
        clearError()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Sign in failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    AnalyticsService.shared.trackSignIn(method: "email")
                    Logger.shared.authInfo("Email sign in successful")
                }
            }
        }
    }
    
    // MARK: - Email Sign Up
    func signUpWithEmail(_ email: String, password: String) {
        setLoading(true)
        clearError()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Sign up failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    AnalyticsService.shared.trackSignUp(method: "email")
                    Logger.shared.authInfo("Email sign up successful")
                }
            }
        }
    }
    
    // MARK: - Anonymous Sign In
    func signInAnonymously() {
        setLoading(true)
        clearError()
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Anonymous sign in failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    AnalyticsService.shared.trackSignIn(method: "anonymous")
                    Logger.shared.authInfo("Anonymous sign in successful")
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            AnalyticsService.shared.trackSignOut()
            Logger.shared.authInfo("User signed out successfully")
        } catch {
            setError("Sign out failed: \(error.localizedDescription)")
            AnalyticsService.shared.recordError(error)
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) {
        setLoading(true)
        clearError()
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Password reset failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    Logger.shared.authInfo("Password reset email sent to: \(email)")
                }
            }
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            setError("No user to delete")
            return
        }
        
        setLoading(true)
        
        user.delete { [weak self] error in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                if let error = error {
                    self?.setError("Account deletion failed: \(error.localizedDescription)")
                    AnalyticsService.shared.recordError(error)
                } else {
                    Logger.shared.authInfo("User account deleted successfully")
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func signInWithCredential(_ credential: AuthCredential, method: String) {
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.setError("Authentication failed: \(error.localizedDescription)")
                AnalyticsService.shared.recordError(error)
            } else {
                AnalyticsService.shared.trackSignIn(method: method)
                Logger.shared.authInfo("\(method.capitalized) authentication successful")
            }
        }
    }
    
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    private func setError(_ message: String) {
        errorMessage = message
        Logger.shared.authError(message)
    }
    
    private func clearError() {
        errorMessage = nil
    }
}

// MARK: - Firebase User Extension
extension FirebaseAuth.User {
    func toUserModel() -> User {
        return User(
            id: uid,
            email: email,
            displayName: displayName,
            photoURL: photoURL,
            isAnonymous: isAnonymous,
            createdAt: metadata.creationDate ?? Date(),
            lastSignInAt: metadata.lastSignInDate ?? Date()
        )
    }
}