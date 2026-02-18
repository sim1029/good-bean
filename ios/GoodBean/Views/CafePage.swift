import SwiftUI

struct CafePage: View {
    var body: some View {
        NavigationStack {
            Text("Cafe")
                .font(.largeTitle.bold())
                .navigationTitle("Cafe")
        }
    }
}

#Preview {
    CafePage()
}
