import Foundation

enum ListingStatus: String, CaseIterable, Hashable {
    case active
    case sold
    case swapped
    case givenAway = "given_away"
    case archived

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .sold: return "Sold"
        case .swapped: return "Swapped"
        case .givenAway: return "Given Away"
        case .archived: return "Archived"
        }
    }
}
