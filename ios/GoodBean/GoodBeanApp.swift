import SwiftUI

@main
struct GoodBeanApp: App {
    var body: some Scene {
        WindowGroup {
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
        }
    }
}
