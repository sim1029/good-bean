import SwiftUI

// MARK: - RequestItemView

struct RequestItemView: View {
    let itemType: CatalogItemType
    let profileId: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var manufacturer = ""
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var manufacturerLabel: String {
        itemType == .bean ? "Roaster" : "Brand"
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !manufacturer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    formCard
                    if let errorMessage {
                        Text(errorMessage)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    submitButton
                }
                .padding(Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Request \(itemType.requestLabel)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.gbAccent)
                }
            }
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 0) {
            formRow(label: itemType == .bean ? "BEAN NAME" : "MODEL NAME") {
                TextField("e.g. \(itemType == .bean ? "Ethiopia Yirgacheffe" : "Linea Mini")", text: $name)
                    .font(Theme.Font.body)
                    .foregroundStyle(Color.gbTextPrimary)
            }
            Divider()
                .background(Color.gbSeparator)
                .padding(.leading, Theme.Spacing.md)
            formRow(label: manufacturerLabel.uppercased()) {
                TextField("e.g. \(itemType == .bean ? "Blue Bottle" : "La Marzocco")", text: $manufacturer)
                    .font(Theme.Font.body)
                    .foregroundStyle(Color.gbTextPrimary)
            }
            Divider()
                .background(Color.gbSeparator)
                .padding(.leading, Theme.Spacing.md)
            formRow(label: "NOTES (OPTIONAL)") {
                TextField("Any additional details...", text: $notes, axis: .vertical)
                    .font(Theme.Font.body)
                    .foregroundStyle(Color.gbTextPrimary)
                    .lineLimit(3...6)
            }
        }
        .gbCardStyle()
    }

    private func formRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
            content()
        }
        .padding(Theme.Spacing.md)
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            Task { await submit() }
        } label: {
            if isSubmitting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text("Submit Request")
            }
        }
        .buttonStyle(GBPrimaryButtonStyle())
        .disabled(!isFormValid || isSubmitting)
        .opacity(isFormValid ? 1 : 0.5)
    }

    // MARK: - Actions

    private func submit() async {
        guard isFormValid else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        let request = CatalogRequest(
            submittedBy: profileId,
            itemType: itemType == .bean ? "bean" : "machine",
            name: name.trimmingCharacters(in: .whitespaces),
            manufacturer: manufacturer.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes,
            imageUrl: nil
        )
        do {
            try await SupabaseService.shared.submitCatalogRequest(request)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
