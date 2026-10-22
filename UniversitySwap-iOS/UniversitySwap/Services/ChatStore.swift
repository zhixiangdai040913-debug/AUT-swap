import Foundation

@MainActor
final class ChatStore: ObservableObject {
    @Published private(set) var threads: [String: [ChatMessage]]
    @Published private(set) var blockedUserIds: Set<String> = []
    @Published private(set) var reportedConversationIds: Set<String> = []

    init(conversations: [Conversation] = MockConversations.all) {
        var threads: [String: [ChatMessage]] = [:]
        for conversation in conversations {
            threads[conversation.id] = MockChatMessages.thread(for: conversation)
        }
        self.threads = threads
    }

    func messages(for conversationId: String) -> [ChatMessage] {
        threads[conversationId] ?? []
    }

    func send(_ text: String, to conversationId: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        threads[conversationId, default: []].append(ChatMessage(text: trimmed, isFromMe: true))
    }

    func isBlocked(_ userId: String) -> Bool {
        blockedUserIds.contains(userId)
    }

    func block(_ userId: String) {
        blockedUserIds.insert(userId)
    }

    func unblock(_ userId: String) {
        blockedUserIds.remove(userId)
    }

    func report(_ conversationId: String) {
        reportedConversationIds.insert(conversationId)
    }
}
