import SwiftUI

struct LoginView: View {
    @Bindable var authManager: AuthenticationManager
    @State private var showPhoneInput = false
    @State private var phoneNumber = ""

    var body: some View {
        ZStack {
            Color.gbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo & tagline
                VStack(spacing: Theme.Spacing.sm) {
                    Text("GoodBean")
                        .font(Theme.Font.display)
                        .foregroundStyle(Color.gbTextPrimary)
                    Text("Track your espresso obsession.")
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: Theme.Spacing.sm) {
                    authButton(
                        label: "Continue with Google",
                        icon: "globe",
                        action: { Task { await authManager.signInWithGoogle() } }
                    )

                    authButton(
                        label: "Continue with Facebook",
                        icon: "person.crop.square",
                        action: { Task { await authManager.signInWithFacebook() } }
                    )

                    authButton(
                        label: "Continue with Phone",
                        icon: "phone",
                        action: { withAnimation { showPhoneInput.toggle() } }
                    )

                    if showPhoneInput {
                        HStack(spacing: Theme.Spacing.sm) {
                            TextField("Phone number", text: $phoneNumber)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)

                            Button("Send") {
                                Task { await authManager.signInWithPhone(phoneNumber) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.gbAccent)
                            .disabled(phoneNumber.isEmpty)
                        }
                        .padding(.horizontal, Theme.Spacing.xs)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    #if DEBUG && targetEnvironment(simulator)
                    Divider()
                        .padding(.vertical, Theme.Spacing.xs)

                    authButton(
                        label: "Test User",
                        icon: "hammer",
                        action: { Task { await authManager.signInAsTestUser() } }
                    )
                    #endif
                }

                // Error banner
                if let error = authManager.error {
                    Text(error)
                        .font(Theme.Font.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, Theme.Spacing.md)
                }

                Spacer()
                    .frame(height: Theme.Spacing.xxl)
            }
            .padding(Theme.Spacing.lg)

            // Loading overlay
            if authManager.isLoading {
                Color.gbBackground.opacity(0.6)
                    .ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
                    .tint(.gbAccent)
            }
        }
    }

    private func authButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm + 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gbTextSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(Theme.Font.body.weight(.medium))
                    .foregroundStyle(Color.gbTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.md)
            .background(Color.gbSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .strokeBorder(Color.gbSeparator, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView(authManager: AuthenticationManager())
}
