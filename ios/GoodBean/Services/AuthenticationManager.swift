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
    private var authListenerTask: Task<Void, Never>?

    func startListening() {
        guard authListenerTask == nil else { return }
        authListenerTask = Task { @MainActor in
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .signedIn, .tokenRefreshed, .userUpdated, .initialSession:
                    currentUserId = session?.user.id
                    isAuthenticated = session != nil
                case .signedOut, .userDeleted:
                    isAuthenticated = false
                    currentUserId = nil
                default:
                    break
                }
            }
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "goodbean://auth/callback")!
            )
        } catch {
            self.error = "Google sign-in failed: \(error.localizedDescription)"
        }
    }

    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            self.error = "Sign-in failed: \(error.localizedDescription)"
        }
    }

    func signUpWithEmail(email: String, password: String, username: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await client.auth.signUp(email: email, password: password)
            let profile = Profile(id: response.user.id, username: username)
            try await SupabaseService.shared.insert(into: "profiles", value: profile)
        } catch {
            self.error = "Sign-up failed: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            self.error = "Sign-out failed: \(error.localizedDescription)"
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
        } catch {
            self.error = "Test user sign-in failed: \(error.localizedDescription)"
        }
    }
    #endif
}
