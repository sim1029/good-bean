import SwiftUI

struct EmailAuthView: View {
    @Bindable var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var hasAttemptedSubmit = false

    // MARK: - Validation

    private var emailError: String? {
        guard hasAttemptedSubmit else { return nil }
        return email.contains("@") ? nil : "Enter a valid email address"
    }

    private var passwordError: String? {
        guard hasAttemptedSubmit else { return nil }
        return password.count >= 8 ? nil : "Password must be at least 8 characters"
    }

    private var confirmPasswordError: String? {
        guard hasAttemptedSubmit, isSignUp else { return nil }
        return confirmPassword == password ? nil : "Passwords do not match"
    }

    private var usernameError: String? {
        guard hasAttemptedSubmit, isSignUp else { return nil }
        return username.isEmpty ? "Username is required" : nil
    }

    private var isFormValid: Bool {
        let base = email.contains("@") && password.count >= 8
        if isSignUp {
            return base && !username.isEmpty && confirmPassword == password
        }
        return base
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        if isSignUp {
                            inputSection("USERNAME", placeholder: "espresso_nerd", text: $username, error: usernameError)
                        }

                        inputSection("EMAIL", placeholder: "you@example.com", text: $email, error: emailError)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        secureSection("PASSWORD", placeholder: "Min. 8 characters", text: $password, error: passwordError)

                        if isSignUp {
                            secureSection("CONFIRM PASSWORD", placeholder: "Repeat password", text: $confirmPassword, error: confirmPasswordError)
                        }

                        // Submit button
                        Button {
                            hasAttemptedSubmit = true
                            guard isFormValid else { return }
                            Task {
                                if isSignUp {
                                    await authManager.signUpWithEmail(
                                        email: email,
                                        password: password,
                                        username: username
                                    )
                                } else {
                                    await authManager.signInWithEmail(email: email, password: password)
                                }
                            }
                        } label: {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(Theme.Font.body.weight(.medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                        }
                        .background(Color.gbAccent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                        .disabled(authManager.isLoading)

                        // Auth error from manager
                        if let error = authManager.error {
                            Text(error)
                                .font(Theme.Font.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Toggle sign-in / sign-up
                        Button {
                            withAnimation {
                                isSignUp.toggle()
                                hasAttemptedSubmit = false
                                authManager.error = nil
                            }
                        } label: {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Color.gbAccent)
                        }
                    }
                    .padding(Theme.Spacing.lg)
                }

                // Loading overlay
                if authManager.isLoading {
                    Color.gbBackground.opacity(0.6)
                        .ignoresSafeArea()
                    ProgressView()
                        .controlSize(.large)
                        .tint(.gbAccent)
                }
            }
            .navigationTitle(isSignUp ? "Create Account" : "Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.gbTextSecondary)
                }
            }
        }
    }

    // MARK: - Field Builders

    private func inputSection(_ label: String, placeholder: String, text: Binding<String>, error: String?) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
            TextField(placeholder, text: text)
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextPrimary)
                .padding(Theme.Spacing.md)
                .background(Color.gbSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .strokeBorder(error != nil ? Color.red.opacity(0.6) : Color.gbSeparator, lineWidth: 1)
                )
            if let error {
                Text(error)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.red.opacity(0.8))
            }
        }
    }

    private func secureSection(_ label: String, placeholder: String, text: Binding<String>, error: String?) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
            SecureField(placeholder, text: text)
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextPrimary)
                .padding(Theme.Spacing.md)
                .background(Color.gbSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .strokeBorder(error != nil ? Color.red.opacity(0.6) : Color.gbSeparator, lineWidth: 1)
                )
            if let error {
                Text(error)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.red.opacity(0.8))
            }
        }
    }
}

#Preview {
    EmailAuthView(authManager: AuthenticationManager())
}
