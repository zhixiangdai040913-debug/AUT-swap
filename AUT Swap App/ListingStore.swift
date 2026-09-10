import SwiftUI

final class ListingStore: ObservableObject {
    @Published private(set) var userListings: [ListingItem] = []

    var allListings: [ListingItem] {
        (userListings + MockData.listings).sorted { $0.postedAt > $1.postedAt }
    }

    func listings(for tab: HomeFeedTab, search: String) -> [ListingItem] {
        var items = allListings

        switch tab {
        case .recommended:
            break
        case .category(let category):
            items = items.filter { $0.category == category }
        }

        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            items = items.filter {
                $0.title.lowercased().contains(query)
                    || $0.description.lowercased().contains(query)
            }
        }
        return items
    }

    func applyFilters(
        _ items: [ListingItem],
        campuses: Set<Campus>,
        categories: Set<ListingCategory>,
        tradeTypes: Set<TradeType>
    ) -> [ListingItem] {
        var result = items.filter { campuses.contains($0.campus) }
        if !categories.isEmpty {
            result = result.filter { categories.contains($0.category) }
        }
        if !tradeTypes.isEmpty {
            result = result.filter { tradeTypes.contains($0.tradeType) }
        }
        return result
    }

    func sorted(_ items: [ListingItem], by sort: CategorySortOption, preferredCampus: Campus) -> [ListingItem] {
        switch sort {
        case .price:
            return items.sorted { priceValue($0) < priceValue($1) }
        case .campus:
            return items.sorted { lhs, rhs in
                let lp = lhs.campus == preferredCampus ? 0 : 1
                let rp = rhs.campus == preferredCampus ? 0 : 1
                if lp != rp { return lp < rp }
                return lhs.postedAt > rhs.postedAt
            }
        }
    }

    func addListing(
        title: String,
        description: String,
        price: Double?,
        tradeType: TradeType,
        campus: Campus,
        category: ListingCategory,
        sellerName: String,
        sellerEmail: String,
        photoURLs: [URL] = []
    ) {
        let id = "user-\(UUID().uuidString.prefix(8))"
        let imageNames = photoURLs.isEmpty
            ? []
            : ListingImageStorage.saveImages(listingId: id, from: photoURLs)
        let item = ListingItem(
            id: id,
            title: title,
            description: description,
            price: price,
            tradeType: tradeType,
            campus: campus,
            category: category,
            trustScore: nil,
            isNewUser: true,
            imageColor: Color(red: 1.0, green: 0.95, blue: 0.88),
            imageSymbol: category.iconName,
            imageNames: imageNames,
            postedAt: Date(),
            sellerName: sellerName,
            sellerEmail: sellerEmail,
            sellerListingCount: 1
        )
        userListings.insert(item, at: 0)
    }

    func listingsBySeller(_ email: String) -> [ListingItem] {
        allListings.filter { $0.sellerEmail.lowercased() == email.lowercased() }
    }

    func removeListing(id: String) {
        userListings.removeAll { $0.id == id }
    }

    private func priceValue(_ item: ListingItem) -> Double {
        if let price = item.price { return price }
        if item.tradeType == .free { return 0 }
        return 999_999
    }
}
