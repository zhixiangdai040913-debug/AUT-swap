import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var filters = ListingFilters()
    @Published var isShowingFilters = false

    func visibleListings(from allListings: [Listing]) -> [Listing] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filtered = allListings.filter { listing in
            guard listing.campus == filters.campus else { return false }
            if !filters.categories.isEmpty, !filters.categories.contains(listing.category) { return false }
            if !filters.tradeTypes.isEmpty, !filters.tradeTypes.contains(listing.tradeType) { return false }
            if !query.isEmpty {
                return listing.title.lowercased().contains(query)
                    || listing.category.rawValue.lowercased().contains(query)
            }
            return true
        }

        switch filters.sort {
        case .nearby:
            return filtered.sorted { $0.distanceKm < $1.distanceKm }
        case .latest:
            return filtered.sorted { $0.postedAt > $1.postedAt }
        case .price:
            return filtered.sorted { priceValue($0) < priceValue($1) }
        }
    }

    var isGiveawayOnly: Bool {
        filters.tradeTypes == [.giveaway]
    }

    func toggleGiveawayOnly() {
        filters.tradeTypes = isGiveawayOnly ? [] : [.giveaway]
    }

    func isCategorySelected(_ category: ListingCategory) -> Bool {
        filters.categories.contains(category)
    }

    func toggleCategory(_ category: ListingCategory) {
        if filters.categories.contains(category) {
            filters.categories.remove(category)
        } else {
            filters.categories.insert(category)
        }
    }

    func applyFilters(_ newFilters: ListingFilters) {
        filters = newFilters
    }

    private func priceValue(_ listing: Listing) -> Double {
        if listing.tradeType == .giveaway { return 0 }
        return listing.price ?? .greatestFiniteMagnitude
    }
}
