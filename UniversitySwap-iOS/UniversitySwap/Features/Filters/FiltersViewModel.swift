import Foundation

@MainActor
final class FiltersViewModel: ObservableObject {
    @Published var filters: ListingFilters

    init(filters: ListingFilters) {
        self.filters = filters
    }

    func toggleCategory(_ category: ListingCategory) {
        if filters.categories.contains(category) {
            filters.categories.remove(category)
        } else {
            filters.categories.insert(category)
        }
    }

    func toggleTradeType(_ type: TradeType) {
        if filters.tradeTypes.contains(type) {
            filters.tradeTypes.remove(type)
        } else {
            filters.tradeTypes.insert(type)
        }
    }
}
