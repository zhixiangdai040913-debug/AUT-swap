import Foundation

enum Campus: String, CaseIterable, Identifiable, Hashable {
    case city = "City"
    case north = "North"
    case south = "South"

    var id: String { rawValue }

    var displayName: String { "\(rawValue) Campus" }
}

enum ListingCategory: String, CaseIterable, Identifiable, Hashable {
    case textbooks = "Textbooks"
    case furniture = "Furniture"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case graduation = "Graduation"
    case other = "Other"

    var id: String { rawValue }
}

enum TradeType: String, CaseIterable, Identifiable, Hashable {
    case giveaway
    case swap
    case sell

    var id: String { rawValue }

    var filterTitle: String {
        switch self {
        case .giveaway: return "Giveaway"
        case .swap: return "Swap"
        case .sell: return "Sell"
        }
    }

    var badgeTitle: String {
        switch self {
        case .giveaway: return "Give Away"
        case .swap: return "Swap"
        case .sell: return "Sell"
        }
    }
}

struct Listing: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let price: Double?
    let tradeType: TradeType
    let campus: Campus
    let category: ListingCategory
    let tags: [String]
    let distanceKm: Double
    let likeCount: Int
    let postedAt: Date
    let seller: Seller
    let pickupNote: String
    let condition: String
    let symbolName: String
    var gallerySymbols: [String] = []
    var imageName: String? = nil
    var imageURL: URL? = nil
    /// Remote listing photos from Firebase Storage / Firestore.
    var imageURLs: [URL] = []
    var photoData: [Data] = []
    /// Firebase Auth UID of the seller (`sellerUserId` in Firestore).
    var sellerUserId: String = ""
    var status: ListingStatus = .active

    var photoSymbols: [String] {
        gallerySymbols.isEmpty ? [symbolName] : gallerySymbols
    }

    var primaryImageURL: URL? {
        imageURL ?? imageURLs.first
    }
}
