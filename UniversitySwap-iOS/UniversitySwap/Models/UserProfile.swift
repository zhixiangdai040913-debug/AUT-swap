import Foundation

struct UserProfile: Identifiable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let campus: Campus?
    let accountType: String
    let createdAt: Date

    var isVerifiedStudent: Bool {
        accountType == "student" || accountType == "staff"
    }

    func asSeller(rating: Double = 5.0, reviewCount: Int = 0) -> Seller {
        Seller(
            id: id,
            name: displayName,
            isVerifiedStudent: isVerifiedStudent,
            rating: rating,
            reviewCount: reviewCount
        )
    }

    static func displayName(from email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? email
        let cleaned = local
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
        return cleaned
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}
