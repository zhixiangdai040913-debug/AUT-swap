import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @FocusState private var isSearchFocused: Bool

    private let horizontalPadding: CGFloat = 16
    private let avatarSize: CGFloat = 52

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 6)
                    .padding(.horizontal, horizontalPadding)
                searchBar
                    .padding(.top, 14)
                    .padding(.horizontal, horizontalPadding)
                conversationList
                    .padding(.top, 10)
            }
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isSearchFocused = false
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.brandOrange)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Messages")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                if AppConfig.useSampleData {
                    Text("Demo chat — in-memory only")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            if viewModel.totalUnread > 0 {
                Text("\(viewModel.totalUnread) unread")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.brandOrange)
            }
            Spacer(minLength: 0)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.icon)
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Search messages").foregroundColor(AppTheme.placeholder)
            )
            .font(.system(size: 14))
            .foregroundColor(AppTheme.textPrimary)
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($isSearchFocused)
            .onSubmit { isSearchFocused = false }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.placeholder)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.fieldFill)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchFocused = true
        }
    }

    // MARK: - List

    @ViewBuilder
    private var conversationList: some View {
        let conversations = viewModel.visibleConversations
        if conversations.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 0) {
                ForEach(conversations) { conversation in
                    NavigationLink(value: AppRoute.chat(conversationId: conversation.id)) {
                        row(for: conversation)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.markAsRead(conversation)
                    })

                    if conversation.id != conversations.last?.id {
                        Rectangle()
                            .fill(AppTheme.divider)
                            .frame(height: 1)
                            .padding(.leading, horizontalPadding + avatarSize + 12)
                    }
                }
            }
        }
    }

    private func row(for conversation: Conversation) -> some View {
        HStack(alignment: .center, spacing: 12) {
            avatar(for: conversation)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(conversation.participant.name)
                        .font(.system(size: 16, weight: conversation.hasUnread ? .bold : .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(viewModel.timeLabel(for: conversation.lastMessageAt))
                        .font(.system(size: 12, weight: conversation.hasUnread ? .semibold : .regular))
                        .foregroundColor(conversation.hasUnread ? AppTheme.brandOrange : AppTheme.textTertiary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "tag")
                        .font(.system(size: 10))
                    Text(conversation.listing.title)
                        .lineLimit(1)
                }
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)

                HStack(alignment: .center, spacing: 8) {
                    lastMessageText(for: conversation)
                        .font(.system(size: 14, weight: conversation.hasUnread ? .medium : .regular))
                        .foregroundColor(conversation.hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    if conversation.hasUnread {
                        unreadBadge(count: conversation.unreadCount)
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens chat")
    }

    private func avatar(for conversation: Conversation) -> some View {
        let category = conversation.listing.category
        return Circle()
            .fill(category.background)
            .frame(width: avatarSize, height: avatarSize)
            .overlay(
                Text(conversation.participant.initials)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(category.tint)
            )
            .overlay(alignment: .bottomTrailing) {
                if conversation.participant.isVerifiedStudent {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.verifiedBlue)
                        .background(Circle().fill(Color.white).padding(1))
                        .offset(x: 2, y: 2)
                        .accessibilityLabel("Verified AUT student")
                }
            }
    }

    private func lastMessageText(for conversation: Conversation) -> Text {
        if conversation.isLastMessageFromMe {
            return Text("You: ").foregroundColor(AppTheme.textTertiary) + Text(conversation.lastMessage)
        }
        return Text(conversation.lastMessage)
    }

    private func unreadBadge(count: Int) -> some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .frame(minWidth: 20, minHeight: 20)
            .background(Capsule().fill(AppTheme.brandOrange))
            .accessibilityLabel("\(count) unread")
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.icon)
            Text(viewModel.searchText.isEmpty ? "No messages yet" : "No conversations found")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text(viewModel.searchText.isEmpty
                 ? "Chat with a seller from any listing to get started."
                 : "Try a different name or item.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 32)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MessagesView()
                .withAppRoutes()
        }
        .environmentObject(ListingStore())
        .environmentObject(ChatStore())
    }
}
