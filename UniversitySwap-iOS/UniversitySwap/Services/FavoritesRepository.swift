import Foundation
import FirebaseFirestore

enum FavoritesRepositoryError: LocalizedError, Equatable {
    case notAuthenticated
    case invalidListingId
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to manage favorites."
        case .invalidListingId:
            return "Invalid listing ID."
        case .underlying(let message):
            return message
        }
    }
}

/// Firestore favorites under `users/{userId}/favorites/{listingId}`.
/// Document ID is the listing ID to prevent duplicates.
final class FavoritesRepository {
    static let shared = FavoritesRepository()

    private var db: Firestore { Firestore.firestore() }

    /// In-memory favorites when `AppConfig.useSampleData` is on (no Firestore writes).
    private var sampleFavoritesByUser: [String: Set<String>] = [:]

    private init() {}

    // MARK: - Public API

    /// Adds a favorite for the authenticated Firebase user.
    /// - Parameters:
    ///   - listingId: Existing `Listing.id` (also used as the favorite document ID).
    ///   - userId: Optional override; must match `Auth.auth().currentUser.uid` when not in sample mode.
    func addFavorite(listingId: String, userId: String? = nil) async throws {
        let uid = try resolveUserId(userId)
        let id = try normalizedListingId(listingId)

        if AppConfig.useSampleData {
            var set = sampleFavoritesByUser[uid] ?? []
            set.insert(id)
            sampleFavoritesByUser[uid] = set
            return
        }

        let data: [String: Any] = [
            "listingId": id,
            "createdAt": FieldValue.serverTimestamp()
        ]

        do {
            // setData on the listing-ID document is idempotent (no duplicates).
            try await favoritesCollection(for: uid).document(id).setData(data, merge: true)
        } catch {
            throw FavoritesRepositoryError.underlying(error.localizedDescription)
        }
    }

    /// Removes a favorite document if it exists.
    func removeFavorite(listingId: String, userId: String? = nil) async throws {
        let uid = try resolveUserId(userId)
        let id = try normalizedListingId(listingId)

        if AppConfig.useSampleData {
            sampleFavoritesByUser[uid]?.remove(id)
            return
        }

        do {
            try await favoritesCollection(for: uid).document(id).delete()
        } catch {
            throw FavoritesRepositoryError.underlying(error.localizedDescription)
        }
    }

    /// Returns whether the listing is in the user's favorites.
    func isFavorited(listingId: String, userId: String? = nil) async throws -> Bool {
        let uid = try resolveUserId(userId)
        let id = try normalizedListingId(listingId)

        if AppConfig.useSampleData {
            return sampleFavoritesByUser[uid]?.contains(id) ?? false
        }

        do {
            let snapshot = try await favoritesCollection(for: uid).document(id).getDocument()
            return snapshot.exists
        } catch {
            throw FavoritesRepositoryError.underlying(error.localizedDescription)
        }
    }

    /// Loads favorite listing IDs for the current user (newest first when timestamps exist).
    func fetchFavoriteListingIds(userId: String? = nil) async throws -> [String] {
        let uid = try resolveUserId(userId)

        if AppConfig.useSampleData {
            let ids = sampleFavoritesByUser[uid] ?? []
            return Array(ids).sorted()
        }

        do {
            let snapshot = try await favoritesCollection(for: uid)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            return snapshot.documents.map { document in
                let data = document.data()
                return (data["listingId"] as? String) ?? document.documentID
            }
        } catch {
            throw FavoritesRepositoryError.underlying(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func favoritesCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("favorites")
    }

    private func normalizedListingId(_ listingId: String) throws -> String {
        let trimmed = listingId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FavoritesRepositoryError.invalidListingId
        }
        return trimmed
    }

    /// Sample mode uses the app session UID (ignore any leftover Firebase Auth user).
    /// Production requires Firebase Auth; an explicit UID must match that Auth user.
    private func resolveUserId(_ explicit: String?) throws -> String {
        if AppConfig.useSampleData {
            let trimmed = explicit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !trimmed.isEmpty {
                return trimmed
            }
            return MockSellers.currentUser.id
        }

        guard let authUID = AuthService.shared.currentUserId, !authUID.isEmpty else {
            throw FavoritesRepositoryError.notAuthenticated
        }
        if let explicit, !explicit.isEmpty, explicit != authUID {
            throw FavoritesRepositoryError.notAuthenticated
        }
        return authUID
    }
}
