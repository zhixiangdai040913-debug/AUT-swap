import PhotosUI
import SwiftUI
import UIKit

struct PickedPhoto: Identifiable {
    let id = UUID()
    let data: Data
    let image: UIImage
}

@MainActor
final class CreateListingViewModel: ObservableObject {
    static let maxPhotos = 5

    @Published var photos: [PickedPhoto] = []
    @Published var pickerItems: [PhotosPickerItem] = []
    @Published var title = ""
    @Published var category: ListingCategory?
    @Published var tradeType: TradeType?
    @Published var priceText = ""
    @Published var lookingFor = ""
    @Published var description = ""
    @Published var campus: Campus = .city
    @Published var isShowingConfirmation = false
    @Published var isShowingDiscardDialog = false
    @Published private(set) var isPosting = false
    @Published var postError: String?

    private let listingRepository: ListingRepository
    private let storageService: StorageService

    init(
        listingRepository: ListingRepository = .shared,
        storageService: StorageService = .shared
    ) {
        self.listingRepository = listingRepository
        self.storageService = storageService
    }

    var remainingPhotoSlots: Int {
        max(0, Self.maxPhotos - photos.count)
    }

    var price: Double? {
        let cleaned = priceText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(cleaned), value > 0 else { return nil }
        return value
    }

    var canSubmit: Bool {
        guard !trimmed(title).isEmpty,
              !trimmed(description).isEmpty,
              category != nil,
              let tradeType
        else { return false }

        switch tradeType {
        case .giveaway: return true
        case .swap: return !trimmed(lookingFor).isEmpty
        case .sell: return price != nil
        }
    }

    var hasChanges: Bool {
        !photos.isEmpty || !trimmed(title).isEmpty || !trimmed(description).isEmpty
            || category != nil || tradeType != nil
    }

    var confirmationSummary: String {
        let typeText: String
        switch tradeType {
        case .giveaway: typeText = "Free"
        case .swap: typeText = "Swap for \(trimmed(lookingFor))"
        case .sell: typeText = "$\(Int(price ?? 0))"
        case nil: typeText = ""
        }
        return "\(trimmed(title)) · \(typeText) · \(campus.displayName)"
    }

    func loadPickedPhotos() async {
        let items = pickerItems
        pickerItems = []
        for item in items {
            guard photos.count < Self.maxPhotos,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else { continue }
            photos.append(PickedPhoto(data: data, image: image))
        }
    }

    func removePhoto(_ photo: PickedPhoto) {
        photos.removeAll { $0.id == photo.id }
    }

    func makeDraft() -> ListingDraft? {
        guard canSubmit, let category, let tradeType else { return nil }

        var fullDescription = trimmed(description)
        if tradeType == .swap {
            fullDescription += "\n\nLooking for: \(trimmed(lookingFor))"
        }

        return ListingDraft(
            title: trimmed(title),
            description: fullDescription,
            price: tradeType == .sell ? price : nil,
            tradeType: tradeType,
            campus: campus,
            category: category,
            condition: tradeType == .giveaway ? "Used · Free pickup" : "Good"
        )
    }

    /// Phase 1: local sample listing. Phase 2+: Storage + Firestore when sample mode is off.
    func publish(seller: Seller) async -> Listing? {
        guard let draft = makeDraft() else { return nil }

        isPosting = true
        postError = nil
        defer { isPosting = false }

        if AppConfig.useSampleData {
            return Listing(
                id: "sample-\(UUID().uuidString.prefix(8))",
                title: draft.title,
                description: draft.description,
                price: draft.price,
                tradeType: draft.tradeType,
                campus: draft.campus,
                category: draft.category,
                tags: [draft.category.rawValue],
                distanceKm: 0.1,
                likeCount: 0,
                postedAt: Date(),
                seller: seller,
                pickupNote: "Message the seller to arrange pickup",
                condition: draft.condition,
                symbolName: draft.category.iconName,
                photoData: photos.map(\.data),
                sellerUserId: seller.id,
                status: .active
            )
        }

        guard !seller.id.isEmpty, seller.id != "unknown" else {
            postError = AuthServiceError.notAuthenticated.localizedDescription
            return nil
        }

        do {
            let listingId = listingRepository.allocateListingId()
            let urls = try await storageService.uploadListingPhotos(
                listingId: listingId,
                sellerId: seller.id,
                photoData: photos.map(\.data)
            )
            return try await listingRepository.createListing(
                draft: draft,
                imageURLs: urls,
                seller: seller,
                listingId: listingId
            )
        } catch {
            postError = error.localizedDescription
            return nil
        }
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
