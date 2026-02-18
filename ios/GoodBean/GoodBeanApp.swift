import SwiftUI

@main
struct GoodBeanApp: App {
    @State private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    LoginView(authManager: authManager)
                }
            }
            .task {
                await authManager.restoreSession()
            }
        }
    }
}
