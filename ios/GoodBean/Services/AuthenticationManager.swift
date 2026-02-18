import Foundation
import Supabase

@MainActor
@Observable
final class AuthenticationManager {
    var isAuthenticated = false
    var currentUserId: UUID?
    var isLoading = false
    var error: String?

    private var client: SupabaseClient { SupabaseService.shared.client }

    func signInWithGoogle() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signInWithOAuth(provider: .google)
            currentUserId = try? await client.auth.session.user.id
            isAuthenticated = true
        } catch {
            self.error = "Google sign-in failed: \(error.localizedDescription)"
        }
    }

    func signInWithFacebook() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signInWithOAuth(provider: .facebook)
            currentUserId = try? await client.auth.session.user.id
            isAuthenticated = true
        } catch {
            self.error = "Facebook sign-in failed: \(error.localizedDescription)"
        }
    }

    func signInWithPhone(_ phoneNumber: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signInWithOTP(phone: phoneNumber)
            // OTP sent — user must verify; for now mark as pending
        } catch {
            self.error = "Phone sign-in failed: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
            isAuthenticated = false
            currentUserId = nil
        } catch {
            self.error = "Sign-out failed: \(error.localizedDescription)"
        }
    }

    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await client.auth.session
            currentUserId = session.user.id
            isAuthenticated = true
        } catch {
            // No valid session — stay on login screen
        }
    }

    #if DEBUG && targetEnvironment(simulator)
    func signInAsTestUser() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signIn(
                email: DevSettings.testUserEmail,
                password: DevSettings.testUserPassword
            )
            currentUserId = DevSettings.testUserId
            isAuthenticated = true
        } catch {
            self.error = "Test user sign-in failed: \(error.localizedDescription)"
        }
    }
    #endif
}
