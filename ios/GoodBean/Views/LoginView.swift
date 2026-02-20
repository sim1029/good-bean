import SwiftUI

struct LoginView: View {
    @Bindable var authManager: AuthenticationManager
    @State private var showEmailAuth = false

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
                        label: "Continue with Email",
                        icon: "envelope",
                        action: { showEmailAuth = true }
                    )

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
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView(authManager: authManager)
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
