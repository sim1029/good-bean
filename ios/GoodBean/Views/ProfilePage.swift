import SwiftUI

struct ProfilePage: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.system(size: 32, weight: .bold, design: .default))

                Text("Manage settings and account")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("User Name")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                            Text("user@example.com")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                }

                VStack(spacing: 8) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "gearshape")
                            Text("Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.primary)
                        .cornerRadius(8)
                    }

                    Button(action: {}) {
                        HStack {
                            Image(systemName: "bell")
                            Text("Notifications")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.primary)
                        .cornerRadius(8)
                    }

                    Button(action: {}) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help & Feedback")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.gray.opacity(0.1))
                        .foregroundStyle(.primary)
                        .cornerRadius(8)
                    }
                }

                Spacer()

                Button(action: {}) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemRed))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
            .padding(24)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfilePage()
}
