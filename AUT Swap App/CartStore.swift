import SwiftUI

final class CartStore: ObservableObject {
    @Published private(set) var itemIDs: [String] = []

    var count: Int { itemIDs.count }

    func items(from listings: [ListingItem]) -> [ListingItem] {
        itemIDs.compactMap { id in listings.first { $0.id == id } }
    }

    func estimatedTotal(from listings: [ListingItem]) -> Double {
        items(from: listings).compactMap(\.price).reduce(0, +)
    }

    init() {
        itemIDs = CartStorage.load()
    }

    func contains(_ item: ListingItem) -> Bool {
        itemIDs.contains(item.id)
    }

    func add(_ item: ListingItem) {
        guard !contains(item) else { return }
        itemIDs.append(item.id)
        persist()
    }

    func remove(_ item: ListingItem) {
        itemIDs.removeAll { $0 == item.id }
        persist()
    }

    func toggle(_ item: ListingItem) {
        if contains(item) { remove(item) } else { add(item) }
    }

    func clear() {
        itemIDs.removeAll()
        persist()
    }

    private func persist() {
        CartStorage.save(itemIDs)
    }
}

enum CartStorage {
    private static let key = "aut_swap_cart_ids"

    static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func save(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: key)
    }
}
