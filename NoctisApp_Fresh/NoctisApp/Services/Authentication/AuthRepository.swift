//
//  AuthRepository.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

class AuthRepository: AuthRepositoryProtocol {
    private let authService = AuthenticationService.shared
    
    var currentUserPublisher: AnyPublisher<User?, Never> {
        authService.$currentUser.eraseToAnyPublisher()
    }
    
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authService.$isAuthenticated
            .map { isAuthenticated in
                return isAuthenticated ? .signedIn : .signedOut
            }
            .eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            
            authService.signInWithEmail(email, password: password)
            
            // Wait a moment for the auth to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { @Sendable in
                if !didResume {
                    if let user = self.authService.currentUser {
                        didResume = true
                        continuation.resume(returning: user)
                    } else if let error = self.authService.errorMessage {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    } else {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                    }
                }
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            
            authService.signUpWithEmail(email, password: password)
            
            // Wait a moment for the auth to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { @Sendable in
                if !didResume {
                    if let user = self.authService.currentUser {
                        didResume = true
                        continuation.resume(returning: user)
                    } else if let error = self.authService.errorMessage {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    } else {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign up failed"]))
                    }
                }
            }
        }
    }
    
    func signInWithGoogle() async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            
            authService.signInWithGoogle()
            
            // Wait a moment for the auth to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { @Sendable in
                if !didResume {
                    if let user = self.authService.currentUser {
                        didResume = true
                        continuation.resume(returning: user)
                    } else if let error = self.authService.errorMessage {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    } else {
                        didResume = true
                        continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google sign in failed"]))
                    }
                }
            }
        }
    }
    
    func signOut() async throws {
        authService.signOut()
    }
    
    func deleteAccount() async throws {
        authService.deleteAccount()
    }
}