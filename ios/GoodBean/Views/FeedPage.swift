import SwiftUI

struct FeedPage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Feed")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Text("Social activities and community shots")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("User Name")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                    Text("Shared a shot")
                                        .font(.system(size: 12, weight: .regular, design: .default))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }

                            Text("Espresso shot details will appear here")
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedPage()
}
