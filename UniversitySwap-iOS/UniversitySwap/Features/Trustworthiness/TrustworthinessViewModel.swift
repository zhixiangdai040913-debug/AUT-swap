import Foundation

@MainActor
final class TrustworthinessViewModel: ObservableObject {
    let userId: String
    let seller: Seller
    let reviews: [Review]
    @Published private(set) var expandedReviewIds: Set<String> = []

    init(userId: String) {
        self.userId = userId
        let seller = MockSellers.seller(id: userId) ?? MockSellers.currentUser
        self.seller = seller
        self.reviews = MockReviews.reviews(for: seller).sorted { $0.createdAt > $1.createdAt }
    }

    var scoreText: String {
        String(format: "%.1f", seller.rating)
    }

    var basedOnText: String {
        "Based on \(reviews.count) review\(reviews.count == 1 ? "" : "s")"
    }

    var positiveCount: Int { count(.positive) }
    var neutralCount: Int { count(.neutral) }
    var negativeCount: Int { count(.negative) }

    func isExpanded(_ review: Review) -> Bool {
        expandedReviewIds.contains(review.id)
    }

    func toggleExpanded(_ review: Review) {
        if expandedReviewIds.contains(review.id) {
            expandedReviewIds.remove(review.id)
        } else {
            expandedReviewIds.insert(review.id)
        }
    }

    func relativeTime(for date: Date, now: Date = Date()) -> String {
        Self.relativeFormatter.localizedString(for: date, relativeTo: now)
    }

    private func count(_ sentiment: Review.Sentiment) -> Int {
        reviews.filter { $0.sentiment == sentiment }.count
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "en_NZ")
        return formatter
    }()
}
