import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var unavailableCount = 0
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var needsSignIn = false

    func load(
        isAuthenticated: Bool,
        userId: String?,
        favoritesStore: FavoritesStore,
        listingStore: ListingStore
    ) async {
        guard isAuthenticated else {
            needsSignIn = true
            listings = []
            unavailableCount = 0
            errorMessage = nil
            isLoading = false
            return
        }

        needsSignIn = false
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await favoritesStore.loadFavorites(userId: userId)

        if let loadError = favoritesStore.lastError {
            errorMessage = loadError
            listings = []
            unavailableCount = 0
            return
        }

        let orderedIDs: [String]
        do {
            orderedIDs = try await FavoritesRepository.shared.fetchFavoriteListingIds(userId: userId)
        } catch {
            orderedIDs = Array(favoritesStore.favoriteIDs).sorted()
        }

        do {
            let result = try await listingStore.resolveListings(ids: orderedIDs)
            listings = result.listings
            unavailableCount = result.missingCount
        } catch {
            errorMessage = error.localizedDescription
            listings = []
            unavailableCount = 0
        }
    }

    func syncRemovedFavorites(favoriteIDs: Set<String>) {
        listings.removeAll { !favoriteIDs.contains($0.id) }
    }
}
