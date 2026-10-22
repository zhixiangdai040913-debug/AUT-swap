import Foundation

enum ProfileRoute: Hashable {
    case myListings
    case favorites
    case myTransactions
    case settings

    var title: String {
        switch self {
        case .myListings: return "My Listings"
        case .favorites: return "Favorites"
        case .myTransactions: return "My Transactions"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .myListings: return "square.grid.2x2"
        case .favorites: return "heart"
        case .myTransactions: return "arrow.left.arrow.right.circle"
        case .settings: return "gearshape"
        }
    }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    let user: Seller
    let level: Int
    let transactionCount: Int

    init(user: Seller = MockSellers.currentUser, level: Int = 2, transactionCount: Int = 12) {
        self.user = user
        self.level = level
        self.transactionCount = transactionCount
    }

    var userId: String { user.id }

    var ratingText: String {
        String(format: "%.1f", user.rating)
    }

    var reviewsText: String {
        "Based on \(user.reviewCount) review\(user.reviewCount == 1 ? "" : "s")"
    }

    var levelText: String {
        "Level \(level) · \(transactionCount) Transaction\(transactionCount == 1 ? "" : "s")"
    }

    func displayName(for email: String?) -> String {
        email ?? user.name
    }

    func initials(for email: String?) -> String {
        guard let localPart = email?.split(separator: "@").first else { return user.initials }
        let words = localPart.split(whereSeparator: { ".-_".contains($0) })
        let letters = words.prefix(2).compactMap { $0.first(where: \.isLetter) }
        let initials = letters.isEmpty ? String(localPart.prefix(1)) : String(letters)
        return initials.uppercased()
    }

    func badgeTitle(for accountType: AUTAccountType?) -> String? {
        switch accountType {
        case .staff: return "AUT Staff"
        case .student: return "AUT Student"
        case nil: return user.isVerifiedStudent ? "AUT Student" : nil
        }
    }

    func listingCount(in listings: [Listing], userId: String? = nil) -> Int {
        let uid = userId ?? user.id
        return listings.filter { listing in
            listing.seller.id == uid
                || (!listing.sellerUserId.isEmpty && listing.sellerUserId == uid)
        }.count
    }
}
