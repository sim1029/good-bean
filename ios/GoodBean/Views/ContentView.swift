import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CafePage()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Cafe")
                }
                .tag(0)

            FeedPage()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Feed")
                }
                .tag(1)

            VisualizePage()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Visualize")
                }
                .tag(2)

            ProfilePage()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
