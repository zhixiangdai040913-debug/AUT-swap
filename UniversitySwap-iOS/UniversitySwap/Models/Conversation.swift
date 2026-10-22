import Foundation

struct Conversation: Identifiable {
    let id: String
    let participant: Seller
    let listing: Listing
    var lastMessage: String
    var lastMessageAt: Date
    var isLastMessageFromMe: Bool
    var unreadCount: Int

    var hasUnread: Bool { unreadCount > 0 }

    init(
        listing: Listing,
        lastMessage: String,
        minutesAgo: Double,
        isLastMessageFromMe: Bool = false,
        unreadCount: Int = 0
    ) {
        self.id = "listing-\(listing.id)"
        self.participant = listing.seller
        self.listing = listing
        self.lastMessage = lastMessage
        self.lastMessageAt = Date().addingTimeInterval(-minutesAgo * 60)
        self.isLastMessageFromMe = isLastMessageFromMe
        self.unreadCount = unreadCount
    }
}

enum MockConversations {
    static var all: [Conversation] {
        let seeds: [(listingId: String, message: String, minutesAgo: Double, fromMe: Bool, unread: Int)] = [
            ("2", "Sure! You can pick it up after 5pm today.", 4, false, 2),
            ("1", "2pm works for me. See you then!", 26, true, 0),
            ("3", "Would you swap it for a stats textbook?", 95, false, 1),
            ("4", "Thanks, it fits perfectly!", 60 * 22, false, 0),
            ("6", "Is the lamp still available?", 60 * 24 * 3, true, 0)
        ]

        return seeds.compactMap { seed in
            MockListings.listing(id: seed.listingId).map {
                Conversation(
                    listing: $0,
                    lastMessage: seed.message,
                    minutesAgo: seed.minutesAgo,
                    isLastMessageFromMe: seed.fromMe,
                    unreadCount: seed.unread
                )
            }
        }
    }
}
