import SwiftUI

struct VisualizePage: View {
    var body: some View {
        NavigationStack {
            Text("Visualize")
                .font(.largeTitle.bold())
                .navigationTitle("Visualize")
        }
    }
}

#Preview {
    VisualizePage()
}
