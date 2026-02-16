import SwiftUI

struct CafePage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Cafe")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Text("Log espresso pulls and manage equipment")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log New Espresso Pull")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }

                    Button(action: {}) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Equipment Setup")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.primary)
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Cafe")
        }
    }
}

#Preview {
    CafePage()
}
