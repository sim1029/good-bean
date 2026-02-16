import SwiftUI

struct VisualizePage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Visualize")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Text("Dashboard of your espresso data")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Average Extraction")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundStyle(.secondary)

                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(0..<7, id: \.self) { _ in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemBlue))
                                        .frame(height: CGFloat.random(in: 40...100))

                                    Text("Day")
                                        .font(.system(size: 10, weight: .regular, design: .default))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                    .padding(12)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Statistics")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Pulls")
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundStyle(.secondary)
                                Text("--")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg Yield")
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundStyle(.secondary)
                                Text("--")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Best Rating")
                                    .font(.system(size: 11, weight: .regular, design: .default))
                                    .foregroundStyle(.secondary)
                                Text("--")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                            }
                        }
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Visualize")
        }
    }
}

#Preview {
    VisualizePage()
}
