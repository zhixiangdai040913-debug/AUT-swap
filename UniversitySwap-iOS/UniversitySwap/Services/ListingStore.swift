import Foundation

@MainActor
final class ListingStore: ObservableObject {
    @Published private(set) var listings: [Listing]
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: String?
    @Published private(set) var isRefreshing = false

    private let repository: ListingRepository
    private let usesSampleData: Bool

    init(
        repository: ListingRepository = .shared,
        seed: [Listing]? = nil,
        useSampleData: Bool = AppConfig.useSampleData
    ) {
        self.repository = repository
        self.usesSampleData = useSampleData
        if let seed {
            self.listings = seed
        } else if useSampleData {
            self.listings = MockListings.all
        } else {
            self.listings = []
        }
    }

    func listing(id: String) -> Listing? {
        listings.first { $0.id == id }
    }

    func add(_ listing: Listing) {
        listings.removeAll { $0.id == listing.id }
        listings.insert(listing, at: 0)
    }

    /// Resolves favorite listing IDs to full models (store first, then Firestore / mocks).
    /// Missing or deleted documents are counted in `missingCount` and omitted from the list.
    func resolveListings(ids: [String]) async throws -> (listings: [Listing], missingCount: Int) {
        guard !ids.isEmpty else { return ([], 0) }

        var byID: [String: Listing] = [:]
        var unresolved: [String] = []

        for id in ids {
            if let local = listing(id: id) {
                byID[id] = local
            } else {
                unresolved.append(id)
            }
        }

        if !unresolved.isEmpty {
            if usesSampleData {
                for listing in MockListings.all where unresolved.contains(listing.id) {
                    byID[listing.id] = listing
                }
            } else {
                let remote = try await repository.fetchListings(ids: unresolved)
                for listing in remote {
                    byID[listing.id] = listing
                    add(listing)
                }
            }
        }

        let resolved = ids.compactMap { byID[$0] }
        return (resolved, ids.count - resolved.count)
    }

    func loadListings(force: Bool = false) async {
        // Phase 1: sample cards only — do not call Firestore.
        if usesSampleData {
            if listings.isEmpty {
                listings = MockListings.all
            }
            loadError = nil
            isLoading = false
            isRefreshing = false
            return
        }

        if isLoading { return }
        if !force && !listings.isEmpty && loadError == nil { return }

        if listings.isEmpty {
            isLoading = true
        } else {
            isRefreshing = true
        }
        loadError = nil

        defer {
            isLoading = false
            isRefreshing = false
        }

        do {
            listings = try await repository.fetchActiveListings()
        } catch {
            loadError = error.localizedDescription
        }
    }
}
