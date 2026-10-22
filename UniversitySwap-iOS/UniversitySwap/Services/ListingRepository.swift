import Foundation
import FirebaseFirestore

enum ListingRepositoryError: LocalizedError {
    case notAuthenticated
    case invalidData
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to create a listing."
        case .invalidData:
            return "Listing data was incomplete."
        case .underlying(let message):
            return message
        }
    }
}

final class ListingRepository {
    static let shared = ListingRepository()

    private var db: Firestore { Firestore.firestore() }
    private var listings: CollectionReference { db.collection("listings") }

    private init() {}

    func fetchActiveListings(limit: Int = 50) async throws -> [Listing] {
        do {
            let snapshot = try await listings
                .whereField("status", isEqualTo: ListingStatus.active.rawValue)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .getDocuments()

            return snapshot.documents.compactMap { Self.decode(id: $0.documentID, data: $0.data()) }
        } catch {
            throw ListingRepositoryError.underlying(error.localizedDescription)
        }
    }

    /// Loads listings by document ID. Missing / deleted docs are omitted.
    /// Firestore `in` queries allow at most 10 values, so IDs are fetched in chunks.
    func fetchListings(ids: [String]) async throws -> [Listing] {
        let uniqueIDs = Array(Set(ids.filter { !$0.isEmpty }))
        guard !uniqueIDs.isEmpty else { return [] }

        var decoded: [String: Listing] = [:]
        do {
            for chunk in uniqueIDs.chunked(into: 10) {
                let snapshot = try await listings
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments()
                for document in snapshot.documents {
                    if let listing = Self.decode(id: document.documentID, data: document.data()) {
                        decoded[listing.id] = listing
                    }
                }
            }
        } catch {
            throw ListingRepositoryError.underlying(error.localizedDescription)
        }

        return ids.compactMap { decoded[$0] }
    }

    func allocateListingId() -> String {
        listings.document().documentID
    }

    func createListing(
        draft: ListingDraft,
        imageURLs: [URL],
        seller: Seller,
        listingId: String? = nil
    ) async throws -> Listing {
        let doc = listingId.map { listings.document($0) } ?? listings.document()
        let listingId = doc.documentID
        let now = Date()

        let listing = Listing(
            id: listingId,
            title: draft.title,
            description: draft.description,
            price: draft.price,
            tradeType: draft.tradeType,
            campus: draft.campus,
            category: draft.category,
            tags: [draft.category.rawValue],
            distanceKm: 0,
            likeCount: 0,
            postedAt: now,
            seller: seller,
            pickupNote: "Message the seller to arrange pickup",
            condition: draft.condition,
            symbolName: draft.category.iconName,
            gallerySymbols: [],
            imageName: nil,
            imageURL: imageURLs.first,
            imageURLs: imageURLs,
            photoData: [],
            sellerUserId: seller.id,
            status: .active
        )

        var data: [String: Any] = [
            "sellerUserId": seller.id,
            "sellerName": seller.name,
            "sellerIsVerified": seller.isVerifiedStudent,
            "sellerRating": seller.rating,
            "sellerReviewCount": seller.reviewCount,
            "title": listing.title,
            "description": listing.description,
            "price": listing.price as Any,
            "category": listing.category.rawValue,
            "listingType": listing.tradeType.firestoreValue,
            "imageURLs": imageURLs.map(\.absoluteString),
            "campus": listing.campus.rawValue,
            "condition": listing.condition,
            "status": ListingStatus.active.rawValue,
            "likeCount": 0,
            "pickupNote": listing.pickupNote,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if listing.price == nil {
            data["price"] = NSNull()
        }

        do {
            try await doc.setData(data)
            return listing
        } catch {
            throw ListingRepositoryError.underlying(error.localizedDescription)
        }
    }

    static func decode(id: String, data: [String: Any]) -> Listing? {
        guard
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = ListingCategory(rawValue: categoryRaw),
            let campusRaw = data["campus"] as? String,
            let campus = Campus(rawValue: campusRaw),
            let listingTypeRaw = data["listingType"] as? String,
            let tradeType = TradeType(firestoreValue: listingTypeRaw)
        else {
            return nil
        }

        let sellerUserId = data["sellerUserId"] as? String ?? ""
        let sellerName = data["sellerName"] as? String ?? "AUT Student"
        let seller = Seller(
            id: sellerUserId,
            name: sellerName,
            isVerifiedStudent: data["sellerIsVerified"] as? Bool ?? true,
            rating: data["sellerRating"] as? Double ?? 5.0,
            reviewCount: data["sellerReviewCount"] as? Int ?? 0
        )

        let urlStrings = data["imageURLs"] as? [String] ?? []
        let imageURLs = urlStrings.compactMap(URL.init(string:))
        let statusRaw = data["status"] as? String ?? ListingStatus.active.rawValue
        let status = ListingStatus(rawValue: statusRaw) ?? .active
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let price = data["price"] as? Double
        let condition = data["condition"] as? String ?? "Good"
        let likeCount = data["likeCount"] as? Int ?? 0
        let pickupNote = data["pickupNote"] as? String ?? "Message the seller to arrange pickup"

        return Listing(
            id: id,
            title: title,
            description: description,
            price: price,
            tradeType: tradeType,
            campus: campus,
            category: category,
            tags: [category.rawValue],
            distanceKm: 0,
            likeCount: likeCount,
            postedAt: createdAt,
            seller: seller,
            pickupNote: pickupNote,
            condition: condition,
            symbolName: category.iconName,
            gallerySymbols: [],
            imageName: nil,
            imageURL: imageURLs.first,
            imageURLs: imageURLs,
            photoData: [],
            sellerUserId: sellerUserId,
            status: status
        )
    }
}

struct ListingDraft {
    let title: String
    let description: String
    let price: Double?
    let tradeType: TradeType
    let campus: Campus
    let category: ListingCategory
    let condition: String
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0, !isEmpty else { return isEmpty ? [] : [self] }
        var result: [[Element]] = []
        result.reserveCapacity((count + size - 1) / size)
        var index = startIndex
        while index < endIndex {
            let end = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(Array(self[index..<end]))
            index = end
        }
        return result
    }
}

extension TradeType {
    /// Firestore `listingType` values: free | swap | sale
    var firestoreValue: String {
        switch self {
        case .giveaway: return "free"
        case .swap: return "swap"
        case .sell: return "sale"
        }
    }

    init?(firestoreValue: String) {
        switch firestoreValue {
        case "free", "giveaway": self = .giveaway
        case "swap": self = .swap
        case "sale", "sell": self = .sell
        default: return nil
        }
    }
}
