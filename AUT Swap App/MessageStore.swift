import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let isFromMe: Bool
    let sentAt: Date
}

struct ChatConversation: Identifiable, Codable, Equatable {
    let id: String
    var participantName: String
    var participantEmail: String
    var listingId: String?
    var listingTitle: String?
    var messages: [ChatMessage]
    var updatedAt: Date
    var unreadCount: Int

    var lastMessagePreview: String {
        messages.last?.text ?? "Say hello…"
    }

    var lastMessageTime: Date {
        messages.last?.sentAt ?? updatedAt
    }
}

final class MessageStore: ObservableObject {
    @Published private(set) var conversations: [ChatConversation] = []

    var unreadTotal: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    init() {
        let saved = MessageStorage.load()
        if saved.isEmpty {
            conversations = Self.seedConversations()
            persist()
        } else {
            conversations = saved.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    func conversation(id: String) -> ChatConversation? {
        conversations.first { $0.id == id }
    }

    @discardableResult
    func startConversation(
        withSellerName name: String,
        sellerEmail: String,
        listing: ListingItem?,
        openingNote: String? = nil
    ) -> String {
        if let existing = conversations.first(where: {
            $0.participantEmail.lowercased() == sellerEmail.lowercased()
                && $0.listingId == listing?.id
        }) {
            return existing.id
        }

        if let existing = conversations.first(where: {
            $0.participantEmail.lowercased() == sellerEmail.lowercased() && listing == nil
        }) {
            return existing.id
        }

        let id = "chat-\(UUID().uuidString.prefix(8))"
        var messages: [ChatMessage] = []
        if let note = openingNote, !note.isEmpty {
            messages.append(
                ChatMessage(
                    id: "msg-\(UUID().uuidString.prefix(8))",
                    text: note,
                    isFromMe: true,
                    sentAt: Date()
                )
            )
        }

        let conversation = ChatConversation(
            id: id,
            participantName: name,
            participantEmail: sellerEmail,
            listingId: listing?.id,
            listingTitle: listing?.title,
            messages: messages,
            updatedAt: Date(),
            unreadCount: 0
        )
        conversations.insert(conversation, at: 0)
        persist()
        return id
    }

    func sendMessage(conversationId: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = conversations.firstIndex(where: { $0.id == conversationId })
        else { return }

        let message = ChatMessage(
            id: "msg-\(UUID().uuidString.prefix(8))",
            text: trimmed,
            isFromMe: true,
            sentAt: Date()
        )
        conversations[index].messages.append(message)
        conversations[index].updatedAt = Date()
        conversations[index].unreadCount = 0
        conversations.sort { $0.updatedAt > $1.updatedAt }
        persist()

        scheduleSellerReply(conversationId: conversationId)
    }

    func markRead(conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        guard conversations[index].unreadCount > 0 else { return }
        conversations[index].unreadCount = 0
        persist()
    }

    func deleteConversation(id: String) {
        conversations.removeAll { $0.id == id }
        persist()
    }

    private func scheduleSellerReply(conversationId: String) {
        let replies = [
            "Hi! Thanks for your interest — is this still available for pickup this week?",
            "Yes, it's available. Happy to meet on campus.",
            "Sure — City campus library entrance works for me.",
            "Price is firm, but I can hold it until Friday.",
            "Sounds good! Message me when you're nearby."
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self,
                  let index = self.conversations.firstIndex(where: { $0.id == conversationId })
            else { return }
            let reply = ChatMessage(
                id: "msg-\(UUID().uuidString.prefix(8))",
                text: replies.randomElement() ?? "Thanks for messaging!",
                isFromMe: false,
                sentAt: Date()
            )
            self.conversations[index].messages.append(reply)
            self.conversations[index].updatedAt = Date()
            self.conversations[index].unreadCount += 1
            self.conversations.sort { $0.updatedAt > $1.updatedAt }
            self.persist()
        }
    }

    private func persist() {
        MessageStorage.save(conversations)
    }

    private static func seedConversations() -> [ChatConversation] {
        let now = Date()
        return [
            ChatConversation(
                id: "seed-1",
                participantName: "Alex Chen",
                participantEmail: "alex.chen@autuni.ac.nz",
                listingId: "1",
                listingTitle: "Calculus Early Transcendentals 3rd Ed",
                messages: [
                    ChatMessage(id: "s1m1", text: "Hi Alex — is the Calculus book still available?", isFromMe: true, sentAt: now.addingTimeInterval(-7200)),
                    ChatMessage(id: "s1m2", text: "Yes! City campus library pickup works for me.", isFromMe: false, sentAt: now.addingTimeInterval(-6800)),
                    ChatMessage(id: "s1m3", text: "Great, I can meet tomorrow afternoon.", isFromMe: true, sentAt: now.addingTimeInterval(-6400))
                ],
                updatedAt: now.addingTimeInterval(-6400),
                unreadCount: 0
            ),
            ChatConversation(
                id: "seed-2",
                participantName: "Sam Taylor",
                participantEmail: "sam.taylor@autuni.ac.nz",
                listingId: "6",
                listingTitle: "iPad Air 4 + Apple Pencil",
                messages: [
                    ChatMessage(id: "s2m1", text: "Is the iPad still for sale?", isFromMe: true, sentAt: now.addingTimeInterval(-3600)),
                    ChatMessage(id: "s2m2", text: "Yes — battery health is 92%. Happy to show it in person.", isFromMe: false, sentAt: now.addingTimeInterval(-3000))
                ],
                updatedAt: now.addingTimeInterval(-3000),
                unreadCount: 1
            ),
            ChatConversation(
                id: "seed-3",
                participantName: "Jordan Lee",
                participantEmail: "jordan.lee@autuni.ac.nz",
                listingId: "11",
                listingTitle: "IKEA Desk + Chair Bundle",
                messages: [
                    ChatMessage(id: "s3m1", text: "Can I pick up the free desk from North campus?", isFromMe: true, sentAt: now.addingTimeInterval(-86400)),
                    ChatMessage(id: "s3m2", text: "Yes — dorm lobby after 5pm this week.", isFromMe: false, sentAt: now.addingTimeInterval(-84000))
                ],
                updatedAt: now.addingTimeInterval(-84000),
                unreadCount: 0
            )
        ]
    }
}

enum MessageStorage {
    private static let key = "aut_swap_messages_v1"

    static func load() -> [ChatConversation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ChatConversation].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(_ conversations: [ChatConversation]) {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
