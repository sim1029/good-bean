#if DEBUG && targetEnvironment(simulator)
import Foundation

enum DevSettings {
    static let testUserEmail = "testuser@goodbean.dev"
    static let testUserPassword = "testpassword123"
    static let testUserId = UUID(uuidString: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")!

    static var isTestUser: Bool {
        (try? SupabaseService.shared.client.auth.currentSession?.user.id) == testUserId
    }
}
#endif
