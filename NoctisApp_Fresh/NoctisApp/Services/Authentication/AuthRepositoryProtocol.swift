//
//  AuthRepositoryProtocol.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import Foundation
import Combine

enum AuthState: Equatable {
    case signedOut
    case loading
    case signedIn
    case error(String)
}

protocol AuthRepositoryProtocol {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String) async throws -> User
    func signInWithGoogle() async throws -> User
    func signOut() async throws
    func deleteAccount() async throws
}