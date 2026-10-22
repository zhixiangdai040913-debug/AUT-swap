import Foundation

@MainActor
final class ListingDetailViewModel: ObservableObject {
    let listingId: String
    @Published var selectedPhotoIndex = 0
    @Published var isDescriptionExpanded = false

    static let paymentMethod = "Cash / Bank Transfer (Offline)"

    init(listingId: String) {
        self.listingId = listingId
    }

    var conversationId: String {
        "listing-\(listingId)"
    }

    func shareText(for listing: Listing?) -> String {
        guard let listing else { return "University Swap" }
        return "\(listing.title) on University Swap"
    }
}
