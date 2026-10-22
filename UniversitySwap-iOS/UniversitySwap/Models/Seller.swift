import Foundation

struct Seller: Identifiable, Hashable {
    let id: String
    let name: String
    let isVerifiedStudent: Bool
    let rating: Double
    let reviewCount: Int

    var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}
