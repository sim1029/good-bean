import SwiftUI

@main
struct GoodBeanApp: App {
    @State private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView(authManager: authManager)
                } else {
                    LoginView(authManager: authManager)
                }
            }
            .onAppear {
                authManager.startListening()
            }
            .onOpenURL { url in
                Task {
                    try? await SupabaseService.shared.client.auth.session(from: url)
                }
            }
        }
    }
}
