import Foundation

struct Review: Identifiable {
    enum Sentiment {
        case positive
        case neutral
        case negative
    }

    let id: String
    let reviewerName: String
    let rating: Int
    let text: String
    let createdAt: Date

    var sentiment: Sentiment {
        switch rating {
        case 4...: return .positive
        case 3: return .neutral
        default: return .negative
        }
    }

    var reviewerInitials: String {
        reviewerName.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}

enum MockReviews {
    private typealias Seed = (reviewer: String, rating: Int, daysAgo: Double, text: String)

    private static let alexChen: [Seed] = [
        ("Jamie Lee", 5, 2, "Great seller! Item was exactly as described. Quick response!"),
        ("Taylor Smith", 5, 5, "Quick and friendly. Easy meetup!"),
        ("Morgan Brown", 5, 7, "Friendly and honest. Would buy again!"),
        ("Casey Wilson", 5, 14, "Smooth transaction. Highly recommend!"),
        ("Priya Patel", 5, 18, "Textbook was in better condition than I expected. Thanks!"),
        ("Liam Nguyen", 4, 23, "Good communication, was a few minutes late to the meetup but all good."),
        ("Sophie Martin", 5, 30, "Super easy swap at City Campus. Lovely to deal with."),
        ("Noah Williams", 5, 38, "Answered all my questions about the laptop. Legit seller."),
        ("Mia Thompson", 5, 45, "Fair price and quick pickup."),
        ("Ethan Walker", 4, 52, "Item as described. Would trade again."),
        ("Aroha Ngata", 5, 60, "Really helpful and patient. Recommended!"),
        ("Jack Robinson", 5, 75, "Fast replies and easy cash handover.")
    ]

    private static let reviewerPool = [
        "Priya Patel", "Liam Nguyen", "Sophie Martin", "Noah Williams", "Mia Thompson",
        "Ethan Walker", "Aroha Ngata", "Jack Robinson", "Jamie Lee", "Taylor Smith",
        "Morgan Brown", "Casey Wilson", "Alex Chen", "Chloe Davis", "Ravi Singh"
    ]

    private static let positiveTexts = [
        "Great to deal with. Item exactly as described!",
        "Quick replies and an easy campus meetup.",
        "Friendly and on time. Would trade again.",
        "Smooth handover, thanks heaps!",
        "Honest about the condition. Recommended.",
        "Fair price and very flexible with pickup."
    ]

    private static let okayText = "Item was fine, but it took a while to arrange the meetup."

    static func reviews(for seller: Seller) -> [Review] {
        let seeds = seller.id == MockSellers.alex.id ? alexChen : generatedSeeds(for: seller)
        let now = Date()
        return seeds.enumerated().map { index, seed in
            Review(
                id: "\(seller.id)-review-\(index)",
                reviewerName: seed.reviewer,
                rating: seed.rating,
                text: seed.text,
                createdAt: now.addingTimeInterval(-seed.daysAgo * 86_400)
            )
        }
    }

    private static func generatedSeeds(for seller: Seller) -> [Seed] {
        let count = seller.reviewCount
        guard count > 0 else { return [] }

        let reviewers = reviewerPool.filter { $0 != seller.name }
        var deficit = max(0, 5 * count - Int((seller.rating * Double(count)).rounded()))

        return (0..<count).map { index in
            var rating = 5
            if deficit >= 2 && index % 3 == 2 {
                rating = 3
                deficit -= 2
            } else if deficit > 0 && index % 2 == 1 {
                rating = 4
                deficit -= 1
            }
            let text = rating >= 4 ? positiveTexts[index % positiveTexts.count] : okayText
            return (reviewers[index % reviewers.count], rating, Double(index * 4 + 1), text)
        }
    }
}
