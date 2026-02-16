import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("GoodBean")
                .font(.system(size: 32, weight: .bold, design: .default))

            Text("Espresso Tracking")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundStyle(.secondary)

            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "dial.medium")
                        .font(.system(size: 20))
                    Text("Dial In")
                        .font(.system(size: 14, weight: .medium, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 20))
                    Text("Inventory")
                        .font(.system(size: 14, weight: .medium, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "chart.line")
                        .font(.system(size: 20))
                    Text("Visualize")
                        .font(.system(size: 14, weight: .medium, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "person.2")
                        .font(.system(size: 20))
                    Text("Social")
                        .font(.system(size: 14, weight: .medium, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            Spacer()

            Text("v0.1.0")
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
