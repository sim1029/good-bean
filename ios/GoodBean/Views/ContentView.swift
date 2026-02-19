import SwiftUI

enum AppTab: Int {
    case cafe, feed, visualize, profile
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .cafe

    var body: some View {
        TabView(selection: $selectedTab) {
            CafePage()
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                }
                .tag(AppTab.cafe)

            FeedPage()
                .tabItem {
                    Image(systemName: "person.2.fill")
                }
                .tag(AppTab.feed)

            VisualizePage()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
                .tag(AppTab.visualize)

            ProfilePage()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                }
                .tag(AppTab.profile)
        }
        .tint(.gbAccent)
    }
}

#Preview {
    ContentView()
}
