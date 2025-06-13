//
//  AuthViewModel.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var authState: AuthState = .signedOut
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Sign In/Up Form Data
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var isSignUpMode = false
    
    private let repository: AuthRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        repository.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
        
        repository.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.authState = state
                self?.isLoading = (state == .loading)
            }
            .store(in: &cancellables)
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        errorMessage = nil
        
        Task {
            do {
                _ = try await repository.signIn(email: email, password: password)
                clearFormData()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        errorMessage = nil
        
        Task {
            do {
                _ = try await repository.signUp(
                    email: email,
                    password: password,
                    displayName: displayName
                )
                clearFormData()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signInWithGoogle() {
        errorMessage = nil
        
        Task {
            do {
                _ = try await repository.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await repository.signOut()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteAccount() {
        Task {
            do {
                try await repository.deleteAccount()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleMode() {
        isSignUpMode.toggle()
        clearFormData()
    }
    
    private func clearFormData() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var isSignedIn: Bool {
        if case .signedIn = authState {
            return true
        }
        return false
    }
    
    var canSubmit: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !displayName.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
}