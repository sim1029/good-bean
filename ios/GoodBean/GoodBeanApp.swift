import SwiftUI

@main
struct GoodBeanApp: App {
    @State private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    TabView {
                        ContentView()
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
                        BeansListView()
                            .tabItem {
                                Label("Beans", systemImage: "bag")
                            }
                    }
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
