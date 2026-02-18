import SwiftUI

struct FeedPage: View {
    var body: some View {
        NavigationStack {
            Text("Feed")
                .font(.largeTitle.bold())
                .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedPage()
}
