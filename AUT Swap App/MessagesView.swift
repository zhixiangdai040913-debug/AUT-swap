import SwiftUI

struct MessagesView: View {
    @ObservedObject var messageStore: MessageStore
    @Binding var selectedConversationId: String?

    var body: some View {
        HStack(spacing: 0) {
            conversationList
                .frame(minWidth: 260, idealWidth: 300, maxWidth: 340)
            Divider()
            if let id = selectedConversationId,
               let conversation = messageStore.conversation(id: id) {
                ChatThreadView(
                    conversation: conversation,
                    messageStore: messageStore
                )
            } else {
                emptyDetail
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
        .onAppear {
            if selectedConversationId == nil {
                selectedConversationId = messageStore.conversations.first?.id
            }
        }
    }

    private var conversationList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Messages")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                if messageStore.unreadTotal > 0 {
                    Text("\(messageStore.unreadTotal) unread")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(SwapTheme.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(SwapTheme.cardBackground)

            if messageStore.conversations.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(SwapTheme.orange.opacity(0.6))
                    Text("No conversations yet")
                        .font(.headline)
                    Text("Tap Contact Seller on a listing to start chatting.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(messageStore.conversations) { conversation in
                            Button(action: {
                                selectedConversationId = conversation.id
                                messageStore.markRead(conversationId: conversation.id)
                            }) {
                                ConversationRowView(
                                    conversation: conversation,
                                    isSelected: selectedConversationId == conversation.id
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 68)
                        }
                    }
                }
            }
        }
        .background(SwapTheme.cardBackground)
    }

    private var emptyDetail: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 48))
                .foregroundColor(SwapTheme.orange.opacity(0.5))
            Text("Select a conversation")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Choose a chat on the left, or contact a seller from a listing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ConversationRowView: View {
    let conversation: ChatConversation
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(SwapTheme.orangeLight)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(conversation.participantName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(SwapTheme.orange)
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(conversation.participantName)
                        .font(.system(size: 14, weight: conversation.unreadCount > 0 ? .bold : .semibold))
                        .lineLimit(1)
                    Spacer()
                    Text(timeLabel(conversation.lastMessageTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                if let title = conversation.listingTitle {
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(SwapTheme.orange)
                        .lineLimit(1)
                }
                HStack {
                    Text(conversation.lastMessagePreview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SwapTheme.priceRed)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(isSelected ? SwapTheme.orangeLight : Color.clear)
        .contentShape(Rectangle())
    }

    private func timeLabel(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ChatThreadView: View {
    let conversation: ChatConversation
    @ObservedObject var messageStore: MessageStore
    @State private var draft = ""

    private var liveConversation: ChatConversation {
        messageStore.conversation(id: conversation.id) ?? conversation
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(SwapTheme.orangeLight)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(liveConversation.participantName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(SwapTheme.orange)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(liveConversation.participantName)
                        .font(.headline)
                    Text(liveConversation.participantEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let title = liveConversation.listingTitle {
                        Text("About: \(title)")
                            .font(.caption2)
                            .foregroundColor(SwapTheme.orange)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(SwapTheme.cardBackground)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(liveConversation.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(20)
                }
                .onAppear {
                    messageStore.markRead(conversationId: liveConversation.id)
                    scrollToBottom(proxy)
                }
                .onChange(of: liveConversation.messages.count) { _ in
                    scrollToBottom(proxy)
                }
            }

            HStack(spacing: 10) {
                TextField("Type a message…", text: $draft)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color(white: 0.96))
                    .cornerRadius(10)
                    .onSubmit(send)

                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(canSend ? SwapTheme.orange : Color.gray)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canSend)
            }
            .padding(16)
            .background(SwapTheme.cardBackground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func send() {
        guard canSend else { return }
        messageStore.sendMessage(conversationId: liveConversation.id, text: draft)
        draft = ""
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let last = liveConversation.messages.last {
            DispatchQueue.main.async {
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 80) }
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(message.isFromMe ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? SwapTheme.orange : Color(white: 0.93))
                    .cornerRadius(16)
                Text(timeString(message.sentAt))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            if !message.isFromMe { Spacer(minLength: 80) }
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
