import Foundation

/// SupabaseClient handles all communication with the Supabase backend.
/// Uses native async/await for concurrency (Swift 6).
actor SupabaseClient {
    static let shared = SupabaseClient()

    private let baseURL: String
    private let apiKey: String

    private init() {
        // These should be read from environment or configuration
        self.baseURL = "https://your-project.supabase.co"
        self.apiKey = "your-anon-key"
    }

    // MARK: - Authentication

    func signUp(email: String, password: String) async throws {
        // TODO: Implement sign up
        print("Sign up: \(email)")
    }

    func signIn(email: String, password: String) async throws {
        // TODO: Implement sign in
        print("Sign in: \(email)")
    }

    func signOut() async throws {
        // TODO: Implement sign out
        print("Sign out")
    }

    // MARK: - Profiles

    func getProfile(id: UUID) async throws -> Profile {
        // TODO: Implement get profile
        return Profile(id: id, username: "demo_user")
    }

    func updateProfile(_ profile: Profile) async throws {
        // TODO: Implement update profile
        print("Update profile: \(profile.username)")
    }
}
