import Foundation

/// SupabaseClient handles all communication with the Supabase backend.
/// Uses native async/await for concurrency (Swift 6).
final class SupabaseClient {
    static let shared = SupabaseClient()

    private let baseURL: String
    private let apiKey: String

    private init() {
        // Configure with your Supabase project
        // Get credentials from https://jbyqmxmftvqhhfuyddls.supabase.co/project/settings/api
        self.baseURL = "https://jbyqmxmftvqhhfuyddls.supabase.co"
        self.apiKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
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

    // MARK: - Beans

    func getBeans() async throws -> [Bean] {
        let url = URL(string: "\(baseURL)/rest/v1/beans?select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SupabaseError.networkError("Failed to fetch beans")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let beans = try decoder.decode([Bean].self, from: data)
        return beans
    }

    func getBean(id: UUID) async throws -> Bean {
        let url = URL(string: "\(baseURL)/rest/v1/beans?id=eq.\(id.uuidString)&select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SupabaseError.networkError("Failed to fetch bean")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let beans = try decoder.decode([Bean].self, from: data)

        guard let bean = beans.first else {
            throw SupabaseError.notFound("Bean not found")
        }

        return bean
    }

    // MARK: - Shot Pulls

    func getShotPulls() async throws -> [ShotPull] {
        let url = URL(string: "\(baseURL)/rest/v1/shot_pulls?select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SupabaseError.networkError("Failed to fetch shot pulls")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let shots = try decoder.decode([ShotPull].self, from: data)
        return shots
    }
}

enum SupabaseError: Error {
    case networkError(String)
    case notFound(String)
    case decodingError(String)
}
