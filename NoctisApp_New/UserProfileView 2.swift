import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                if let user = authService.currentUser {
                    // Profile Section
                    Section {
                        HStack {
                            AsyncImage(url: user.photoURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Color("Primary"))
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            
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
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
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
                            authService.signOut()
                            AnalyticsService.shared.trackCustomEvent(name: "user_signed_out_from_profile")
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(Color("TextPrimary"))
                        }
                    }
                    
                    // App Information
                    Section("App") {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundColor(Color("TextPrimary"))
                            
                            Spacer()
                            
                            Text(AppEnvironment.shared.appVersion)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        
                        HStack {
                            Label("Build", systemImage: "hammer")
                                .foregroundColor(Color("TextPrimary"))
                            
                            Spacer()
                            
                            Text(AppEnvironment.shared.buildNumber)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        
                        HStack {
                            Label("Environment", systemImage: "gear")
                                .foregroundColor(Color("TextPrimary"))
                            
                            Spacer()
                            
                            Text(AppEnvironment.shared.current.displayName)
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    
                    // Danger Zone
                    if !user.isAnonymous {
                        Section("Danger Zone") {
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Label("Delete Account", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color("Background"))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                authService.deleteAccount()
                AnalyticsService.shared.trackCustomEvent(name: "account_deleted")
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.")
        }
        .onAppear {
            AnalyticsService.shared.trackScreen("User Profile")
        }
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AuthenticationService.shared)
}