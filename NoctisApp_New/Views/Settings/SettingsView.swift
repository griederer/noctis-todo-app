//
//  SettingsView.swift
//  NoctisApp
//
//  Created by Claude on 2025-06-10.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                if let user = authService.currentUser {
                    Section {
                        userProfileRow(user)
                    }
                    
                    // Account Actions
                    Section("Account") {
                        if user.isAnonymous {
                            NavigationLink(destination: AuthenticationView()) {
                                Label("Create Account", systemImage: "person.badge.plus")
                                    .foregroundColor(Color("Primary"))
                            }
                        } else {
                            Button(action: {
                                authService.resetPassword(email: user.email ?? "")
                            }) {
                                Label("Reset Password", systemImage: "key")
                                    .foregroundColor(Color("TextPrimary"))
                            }
                            .disabled(user.email == nil)
                        }
                        
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(Color("TextPrimary"))
                        }
                    }
                }
                
                // App Preferences
                Section("Preferences") {
                    HStack {
                        Label("Theme", systemImage: "moon.stars.fill")
                            .foregroundColor(Color("Primary"))
                        
                        Spacer()
                        
                        Text("Dark")
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    HStack {
                        Label("Notifications", systemImage: "bell")
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("Enabled")
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .foregroundColor(Color("TextPrimary"))
                    }
                }
                
                // Statistics
                Section("Your Activity") {
                    NavigationLink(destination: UserStatsView()) {
                        Label("View Statistics", systemImage: "chart.bar")
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    NavigationLink(destination: UserProfileView()) {
                        Label("Detailed Profile", systemImage: "person.circle")
                            .foregroundColor(Color("TextPrimary"))
                    }
                }
                
                // App Information
                Section("About Noctis") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                        
                        Text("\(AppEnvironment.shared.appVersion) (\(AppEnvironment.shared.buildNumber))")
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    HStack {
                        Label("Environment", systemImage: "gear")
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                        
                        Text(AppEnvironment.shared.current.displayName)
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Link(destination: URL(string: "https://noctis.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    Link(destination: URL(string: "https://noctis.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                            .foregroundColor(Color("TextPrimary"))
                    }
                    
                    Link(destination: URL(string: "mailto:support@noctis.app")!) {
                        Label("Contact Support", systemImage: "envelope")
                            .foregroundColor(Color("TextPrimary"))
                    }
                }
                
                // Danger Zone
                if let user = authService.currentUser, !user.isAnonymous {
                    Section("Danger Zone") {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color("Background"))
        }
        .preferredColorScheme(.dark)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authService.signOut()
                AnalyticsService.shared.trackCustomEvent(name: "user_signed_out_from_settings")
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                authService.deleteAccount()
                AnalyticsService.shared.trackCustomEvent(name: "account_deleted_from_settings")
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.")
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("Settings")
        }
    }
    
    // MARK: - User Profile Row
    private func userProfileRow(_ user: User) -> some View {
        HStack(spacing: 12) {
            // Profile Image
            AsyncImage(url: user.photoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("Primary"))
                    .font(.system(size: 40))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                if let displayName = user.displayName {
                    Text(displayName)
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                } else {
                    Text("Anonymous User")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                }
                
                if let email = user.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                
                HStack(spacing: 8) {
                    if user.isAnonymous {
                        Text("Guest Account")
                            .font(.caption)
                            .foregroundColor(Color("Primary"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color("Primary").opacity(0.2))
                            )
                    }
                    
                    Text("Joined \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(Color("TextTertiary"))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Supporting Views
struct DataExportView: View {
    var body: some View {
        VStack {
            Text("Data Export")
                .font(.title)
                .padding()
            
            Text("Feature coming soon - Export your todos, habits, and journal entries")
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("Background"))
    }
}

struct UserStatsView: View {
    var body: some View {
        VStack {
            Text("Your Statistics")
                .font(.title)
                .padding()
            
            Text("Detailed analytics coming soon - Track your productivity patterns and growth")
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("Background"))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationService.shared)
}

