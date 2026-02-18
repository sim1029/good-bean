import SwiftUI

struct LoginView: View {
    @Bindable var authManager: AuthenticationManager
    @State private var showPhoneInput = false
    @State private var phoneNumber = ""

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Logo & tagline
                VStack(spacing: 8) {
                    Text("GoodBean")
                        .font(.system(size: 36, weight: .bold, design: .default))
                    Text("Track your espresso obsession.")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Auth buttons
                VStack(spacing: 12) {
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
                        HStack(spacing: 8) {
                            TextField("Phone number", text: $phoneNumber)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)

                            Button("Send") {
                                Task { await authManager.signInWithPhone(phoneNumber) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primary)
                            .disabled(phoneNumber.isEmpty)
                        }
                        .padding(.horizontal, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    #if DEBUG && targetEnvironment(simulator)
                    Divider()
                        .padding(.vertical, 4)

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
                        .font(.system(size: 13))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }

                Spacer()
                    .frame(height: 48)
            }
            .padding(24)

            // Loading overlay
            if authManager.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
            }
        }
    }

    private func authButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .default))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView(authManager: AuthenticationManager())
}
