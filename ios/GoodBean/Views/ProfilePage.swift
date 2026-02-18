import SwiftUI

struct ProfilePage: View {
    var body: some View {
        NavigationStack {
            Text("Profile")
                .font(.largeTitle.bold())
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfilePage()
}
