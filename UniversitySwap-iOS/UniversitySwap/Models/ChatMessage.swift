import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let sentAt: Date
    let isFromMe: Bool

    init(id: UUID = UUID(), text: String, sentAt: Date = Date(), isFromMe: Bool) {
        self.id = id
        self.text = text
        self.sentAt = sentAt
        self.isFromMe = isFromMe
    }
}

enum MockChatMessages {
    private static let scripts: [String: [(isFromMe: Bool, text: String)]] = [
        "listing-1": [
            (false, "Hi! Is this item still available?"),
            (true, "Yes, it is! Are you available tomorrow afternoon?"),
            (false, "Great! I can meet at City Campus. Does 2pm work for you?"),
            (true, "2pm works for me. See you then!")
        ],
        "listing-2": [
            (true, "Hi Jamie, is the office chair still free?"),
            (false, "Yes it is! Nobody has claimed it yet."),
            (true, "Awesome, when can I come and get it?"),
            (false, "Sure! You can pick it up after 5pm today.")
        ],
        "listing-3": [
            (true, "Hey! Is the psychology textbook still up for swap?"),
            (false, "Hi! Yes, still available."),
            (false, "Would you swap it for a stats textbook?")
        ],
        "listing-4": [
            (false, "Hi, I picked up the hoodie earlier."),
            (true, "Great, hope it fits!"),
            (false, "Thanks, it fits perfectly!")
        ],
        "listing-6": [
            (true, "Is the lamp still available?")
        ]
    ]

    static func thread(for conversation: Conversation) -> [ChatMessage] {
        guard let script = scripts[conversation.id] else { return [] }
        let spacing: TimeInterval = 2 * 60
        return script.enumerated().map { index, line in
            let offset = Double(script.count - 1 - index) * spacing
            return ChatMessage(
                text: line.text,
                sentAt: conversation.lastMessageAt.addingTimeInterval(-offset),
                isFromMe: line.isFromMe
            )
        }
    }
}
