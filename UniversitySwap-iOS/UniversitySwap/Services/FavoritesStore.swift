import Foundation

enum FavoriteToggleResult: Equatable {
    case success
    case needsSignIn
    case ignoredBusy
    case failure(String)
}

/// Observable cache of the signed-in user's favorite listing IDs.
@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var pendingIDs: Set<String> = []
    @Published private(set) var lastError: String?

    private let repository: FavoritesRepository

    init(repository: FavoritesRepository = .shared) {
        self.repository = repository
    }

    func isFavorited(_ listingId: String) -> Bool {
        favoriteIDs.contains(listingId)
    }

    func isToggling(_ listingId: String) -> Bool {
        pendingIDs.contains(listingId)
    }

    /// Reloads favorite IDs for the Firebase Auth user (or sample UID when provided).
    func loadFavorites(userId: String? = nil) async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            let ids = try await repository.fetchFavoriteListingIds(userId: userId)
            favoriteIDs = Set(ids)
        } catch let error as FavoritesRepositoryError where error == .notAuthenticated {
            favoriteIDs = []
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Optimistic toggle with rollback on failure. Ignores taps while a request is in flight.
    func toggleFavorite(
        listingId: String,
        userId: String? = nil,
        isAuthenticated: Bool
    ) async -> FavoriteToggleResult {
        guard isAuthenticated else {
            return .needsSignIn
        }
        guard !listingId.isEmpty else {
            return .failure("Invalid listing.")
        }
        guard !pendingIDs.contains(listingId) else {
            return .ignoredBusy
        }

        pendingIDs.insert(listingId)
        lastError = nil

        let wasFavorited = favoriteIDs.contains(listingId)
        // Optimistic UI update
        if wasFavorited {
            favoriteIDs.remove(listingId)
        } else {
            favoriteIDs.insert(listingId)
        }

        do {
            if wasFavorited {
                try await repository.removeFavorite(listingId: listingId, userId: userId)
            } else {
                try await repository.addFavorite(listingId: listingId, userId: userId)
            }
            pendingIDs.remove(listingId)
            return .success
        } catch {
            // Roll back so UI never stays wrong after an error.
            if wasFavorited {
                favoriteIDs.insert(listingId)
            } else {
                favoriteIDs.remove(listingId)
            }
            pendingIDs.remove(listingId)
            let message = error.localizedDescription
            lastError = message
            return .failure(message)
        }
    }

    func clear() {
        favoriteIDs = []
        pendingIDs = []
        lastError = nil
        isLoading = false
    }
}
