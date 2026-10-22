import Foundation

enum ListingSort: CaseIterable, Identifiable, Hashable {
    case nearby
    case latest
    case price

    var id: Self { self }

    var title: String {
        switch self {
        case .nearby: return "Recommends"
        case .latest: return "Latest"
        case .price: return "Price"
        }
    }
}

struct ListingFilters: Equatable {
    var campus: Campus = .city
    var categories: Set<ListingCategory> = []
    var tradeTypes: Set<TradeType> = []
    var sort: ListingSort = .nearby
}
