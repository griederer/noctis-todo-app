import SwiftUI
import GoogleSignIn

struct AuthenticationView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 16) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("Primary"))
                        
                        Text("NOCTIS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Your nighttime productivity companion")
                            .font(.subheadline)
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Authentication Form
                    VStack(spacing: 20) {
                        if showingSignUp {
                            signUpForm
                        } else {
                            signInForm
                        }
                        
                        // Toggle between Sign In / Sign Up
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSignUp.toggle()
                                clearForm()
                            }
                        }) {
                            Text(showingSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.footnote)
                                .foregroundColor(Color("Primary"))
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color("Surface"))
                            
                            Text("or")
                                .font(.caption)
                                .foregroundColor(Color("TextSecondary"))
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color("Surface"))
                        }
                        .padding(.vertical, 8)
                        
                        // Google Sign In
                        Button(action: {
                            authService.signInWithGoogle()
                            AnalyticsService.shared.trackCustomEvent(name: "google_signin_attempted")
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.white)
                                
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red)
                            )
                        }
                        .disabled(authService.isLoading)
                        
                        // Anonymous Sign In
                        Button(action: {
                            authService.signInAnonymously()
                            AnalyticsService.shared.trackCustomEvent(name: "anonymous_signin_attempted")
                        }) {
                            Text("Continue as Guest")
                                .font(.footnote)
                                .foregroundColor(Color("TextSecondary"))
                        }
                        .disabled(authService.isLoading)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                
                // Loading Overlay
                if authService.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("Primary")))
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            AnalyticsService.shared.trackScreen("Authentication")
        }
    }
    
    // MARK: - Sign In Form
    private var signInForm: some View {
        VStack(spacing: 16) {
            CustomTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope"
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            
            CustomTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock",
                isSecure: true
            )
            
            Button(action: {
                authService.signInWithEmail(email, password: password)
                AnalyticsService.shared.trackCustomEvent(name: "email_signin_attempted")
            }) {
                Text("Sign In")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Primary"))
                    )
            }
            .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
            
            Button(action: {
                authService.resetPassword(email: email)
            }) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(Color("Primary"))
            }
            .disabled(email.isEmpty)
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 16) {
            CustomTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope"
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            
            CustomTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock",
                isSecure: true
            )
            
            CustomTextField(
                text: $confirmPassword,
                placeholder: "Confirm Password",
                icon: "lock",
                isSecure: true
            )
            
            Button(action: {
                guard password == confirmPassword else {
                    authService.errorMessage = "Passwords don't match"
                    return
                }
                
                authService.signUpWithEmail(email, password: password)
                AnalyticsService.shared.trackCustomEvent(name: "email_signup_attempted")
            }) {
                Text("Sign Up")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Primary"))
                    )
            }
            .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || authService.isLoading)
        }
    }
    
    // MARK: - Helper Methods
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        authService.errorMessage = nil
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("TextSecondary"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color("TextPrimary"))
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Color("TextPrimary"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
        )
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationService.shared)
}