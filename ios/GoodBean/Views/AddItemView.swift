import SwiftUI

// MARK: - CatalogItemType

enum CatalogItemType {
    case bean, machine

    var title: String             { self == .bean ? "Add Bean"        : "Add Machine"    }
    var searchPlaceholder: String { self == .bean ? "Name or roaster" : "Brand or model" }
    var requestLabel: String      { self == .bean ? "Bean"            : "Machine"        }
    var placeholderIcon: String   { self == .bean ? "leaf"            : "cup.and.saucer" }
}

// MARK: - CatalogEntry
// Wraps the two catalog search result types for use in ForEach / grid.

enum CatalogEntry: Identifiable {
    case bean(BeanCatalogSearchResult)
    case machine(MachineCatalogSearchResult)

    var id: UUID {
        switch self {
        case .bean(let b):    b.id
        case .machine(let m): m.id
        }
    }
    var primaryName: String {
        switch self {
        case .bean(let b):    b.name
        case .machine(let m): m.displayName
        }
    }
    var secondaryName: String {
        switch self {
        case .bean(let b):    b.roaster
        case .machine(let m): m.model
        }
    }
    var imageUrl: String? {
        switch self {
        case .bean(let b):    b.imageUrl
        case .machine(let m): m.imageUrl
        }
    }
    var isOwned: Bool {
        switch self {
        case .bean(let b):    b.isOwned
        case .machine(let m): m.isOwned
        }
    }
    var inventoryId: UUID? {
        switch self {
        case .bean(let b):    b.inventoryId
        case .machine(let m): m.inventoryId
        }
    }
}

// MARK: - AddItemView

struct AddItemView: View {
    let itemType: CatalogItemType
    let profileId: UUID
    let onSelect: () async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var entries: [CatalogEntry] = []
    @State private var isLoading = false
    @State private var debounceTask: Task<Void, Never>?
    @State private var showRequest = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(Theme.Spacing.md)

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if entries.isEmpty {
                    noResultsView
                } else {
                    catalogGrid
                }
            }
            .background(Color.gbBackground)
            .navigationTitle(itemType.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.gbAccent)
                }
            }
            .sheet(isPresented: $showRequest) {
                RequestItemView(itemType: itemType, profileId: profileId)
            }
        }
        .task { await performSearch("") }
        .onChange(of: searchText) { _, new in
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await performSearch(new)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gbTextTertiary)
            TextField(itemType.searchPlaceholder, text: $searchText)
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextPrimary)
                .autocorrectionDisabled()
        }
        .padding(Theme.Spacing.md)
        .background(Color.gbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .strokeBorder(Color.gbSeparator, lineWidth: 1)
        )
    }

    // MARK: - Catalog Grid

    private var catalogGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: Theme.Spacing.sm),
            GridItem(.flexible(), spacing: Theme.Spacing.sm)
        ]
        return ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                ForEach(entries) { entry in
                    Button {
                        Task { await select(entry) }
                    } label: {
                        CatalogGridCard(entry: entry, placeholderIcon: itemType.placeholderIcon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            Text(searchText.isEmpty
                 ? "No \(itemType == .bean ? "beans" : "machines") in the catalog yet."
                 : "No results for \"\(searchText)\"")
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextSecondary)
            Button("Request a new \(itemType.requestLabel)") {
                showRequest = true
            }
            .buttonStyle(GBSecondaryButtonStyle())
            .padding(.horizontal, Theme.Spacing.xl)
            Spacer()
        }
    }

    // MARK: - Data

    private func performSearch(_ query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            switch itemType {
            case .bean:
                let results = try await SupabaseService.shared.searchBeanCatalog(query: query)
                entries = results.map { .bean($0) }
            case .machine:
                let results = try await SupabaseService.shared.searchMachineCatalog(query: query)
                entries = results.map { .machine($0) }
            }
        } catch {
            entries = []
        }
    }

    /// Selects a catalog entry:
    /// - If the user already owns it (isOwned), use the existing inventory ID.
    /// - Otherwise, auto-add to inventory first, then set as active.
    private func select(_ entry: CatalogEntry) async {
        do {
            switch entry {
            case .bean(let result):
                let inventoryId = try await resolvedBeanInventoryId(result)
                try await SupabaseService.shared.setActiveBean(userId: profileId, beanId: inventoryId)
            case .machine(let result):
                let inventoryId = try await resolvedMachineInventoryId(result)
                try await SupabaseService.shared.setActiveMachine(userId: profileId, machineId: inventoryId)
            }
            await onSelect()
            dismiss()
        } catch {
            // silently fail — user can retry
        }
    }

    private func resolvedBeanInventoryId(_ result: BeanCatalogSearchResult) async throws -> UUID {
        if let existing = result.inventoryId { return existing }
        return try await SupabaseService.shared.addBeanToInventory(catalogId: result.id, userId: profileId)
    }

    private func resolvedMachineInventoryId(_ result: MachineCatalogSearchResult) async throws -> UUID {
        if let existing = result.inventoryId { return existing }
        return try await SupabaseService.shared.addMachineToInventory(catalogId: result.id, userId: profileId)
    }
}

// MARK: - CatalogGridCard

private struct CatalogGridCard: View {
    let entry: CatalogEntry
    let placeholderIcon: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                imageArea
                Text(entry.primaryName)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                    .lineLimit(1)
                Text(entry.secondaryName)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)
                    .lineLimit(1)
            }
            .padding(Theme.Spacing.sm)
            .gbCardStyle()

            if entry.isOwned {
                Text("OWNED")
                    .font(Theme.Font.caption.weight(.semibold))
                    .foregroundStyle(Color.gbAccent)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Color.gbAccent.opacity(0.12))
                    .clipShape(Capsule())
                    .padding(Theme.Spacing.sm)
            }
        }
    }

    @ViewBuilder
    private var imageArea: some View {
        if let urlString = entry.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    imagePlaceholder
                }
            }
            .frame(height: 100)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        } else {
            imagePlaceholder
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.md)
            .fill(Color.gbBackground)
            .overlay(
                Image(systemName: placeholderIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color.gbTextTertiary)
            )
    }
}
