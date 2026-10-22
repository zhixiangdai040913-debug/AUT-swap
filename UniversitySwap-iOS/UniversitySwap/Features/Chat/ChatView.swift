import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var listingStore: ListingStore
    @EnvironmentObject private var chatStore: ChatStore
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    private let horizontalPadding: CGFloat = 16
    private let bottomAnchor = "chat-bottom"

    init(conversationId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversationId: conversationId))
    }

    private var listing: Listing? {
        viewModel.listingId.flatMap { listingStore.listing(id: $0) }
    }

    private var partner: Seller? { listing?.seller }

    private var isBlocked: Bool {
        partner.map { chatStore.isBlocked($0.id) } ?? false
    }

    private var isReported: Bool {
        chatStore.reportedConversationIds.contains(viewModel.conversationId)
    }

    var body: some View {
        let messages = chatStore.messages(for: viewModel.conversationId)

        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    if messages.isEmpty {
                        emptyIntro
                    }
                    ForEach(messages) { message in
                        messageRow(message)
                            .id(message.id)
                    }
                    Color.clear
                        .frame(height: 1)
                        .id(bottomAnchor)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 14)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
            .onChange(of: messages.count) { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(bottomAnchor, anchor: .bottom)
                }
            }
            .onChange(of: isInputFocused) { isFocused in
                guard isFocused else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let listing {
                listingCard(listing)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar { toolbarContent }
        .confirmationDialog(
            "Why are you reporting this conversation?",
            isPresented: $viewModel.isShowingReportOptions,
            titleVisibility: .visible
        ) {
            ForEach(ChatViewModel.reportReasons, id: \.self) { reason in
                Button(reason) {
                    viewModel.report(reason: reason, using: chatStore)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Thanks for letting us know", isPresented: $viewModel.isShowingReportConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We'll review this conversation. If you feel unsafe, you can also block this user.")
        }
        .alert(
            "Block \(partner?.name ?? "this user")?",
            isPresented: $viewModel.isShowingBlockConfirmation
        ) {
            Button("Block", role: .destructive) {
                if let partner {
                    chatStore.block(partner.id)
                    isInputFocused = false
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("They won't be able to message you, and you won't be able to send messages in this chat.")
        }
    }

    // MARK: - Header

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if let partner {
                NavigationLink(value: AppRoute.trustworthiness(userId: partner.id)) {
                    HStack(spacing: 10) {
                        avatar(for: partner, size: 34, fontSize: 13)
                        Text(partner.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Shows trustworthiness score and reviews")
            } else {
                Text("Chat")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    viewModel.isShowingReportOptions = true
                } label: {
                    Label(isReported ? "Reported" : "Report", systemImage: "flag")
                }
                .disabled(isReported)

                if isBlocked {
                    Button {
                        partner.map { chatStore.unblock($0.id) }
                    } label: {
                        Label("Unblock", systemImage: "person.crop.circle.badge.checkmark")
                    }
                } else {
                    Button(role: .destructive) {
                        viewModel.isShowingBlockConfirmation = true
                    } label: {
                        Label("Block", systemImage: "nosign")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("More options")
        }
    }

    private func avatar(for seller: Seller, size: CGFloat, fontSize: CGFloat) -> some View {
        let category = listing?.category
        return Circle()
            .fill(category?.background ?? AppTheme.fieldFill)
            .frame(width: size, height: size)
            .overlay(
                Text(seller.initials)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(category?.tint ?? AppTheme.textSecondary)
            )
    }

    // MARK: - Listing card

    private func listingCard(_ listing: Listing) -> some View {
        NavigationLink(value: AppRoute.listingDetail(listingId: listing.id)) {
            HStack(spacing: 12) {
                listingThumbnail(listing)
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(listing.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    listingPrice(listing)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 11))
                        Text("\(listing.campus.displayName) · \(String(format: "%.1f", listing.distanceKm)) km")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle().fill(AppTheme.divider).frame(height: 1)
        }
        .accessibilityHint("Opens item details")
    }

    @ViewBuilder
    private func listingThumbnail(_ listing: Listing) -> some View {
        if let data = listing.photoData.first, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let imageName = listing.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                listing.category.background
                Image(systemName: listing.symbolName)
                    .font(.system(size: 24))
                    .foregroundColor(listing.category.tint.opacity(0.85))
            }
        }
    }

    @ViewBuilder
    private func listingPrice(_ listing: Listing) -> some View {
        if listing.tradeType == .giveaway {
            Text("Free")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.giveawayGreen)
        } else if let price = listing.price {
            Text("$\(Int(price))")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppTheme.brandOrange)
        } else {
            Text("Swap")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(TradeType.swap.badgeColor)
        }
    }

    // MARK: - Messages

    @ViewBuilder
    private func messageRow(_ message: ChatMessage) -> some View {
        if message.isFromMe {
            HStack {
                Spacer(minLength: 64)
                VStack(alignment: .trailing, spacing: 4) {
                    bubble(message.text, isFromMe: true)
                    timeText(for: message)
                }
            }
        } else {
            HStack(alignment: .top, spacing: 8) {
                if let partner {
                    avatar(for: partner, size: 32, fontSize: 12)
                }
                VStack(alignment: .leading, spacing: 4) {
                    bubble(message.text, isFromMe: false)
                    timeText(for: message)
                }
                Spacer(minLength: 48)
            }
        }
    }

    private func bubble(_ text: String, isFromMe: Bool) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(isFromMe ? .white : AppTheme.textPrimary)
            .lineSpacing(2)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isFromMe ? AppTheme.brandOrange : AppTheme.fieldFill)
            )
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }

    private func timeText(for message: ChatMessage) -> some View {
        Text(viewModel.timeLabel(for: message.sentAt))
            .font(.system(size: 11))
            .foregroundColor(AppTheme.textTertiary)
            .padding(.horizontal, 4)
    }

    private var emptyIntro: some View {
        VStack(spacing: 8) {
            Image(systemName: "hand.wave")
                .font(.system(size: 28))
                .foregroundColor(AppTheme.icon)
            Text("Say hi to \(partner?.name ?? "the seller")")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Agree on a campus meetup spot. Payment is cash or bank transfer, offline only.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if isBlocked {
                blockedBanner
            } else {
                inputRow
            }
            HStack(spacing: 12) {
                reportButton
                blockButton
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.divider).frame(height: 1)
        }
    }

    private var inputRow: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "",
                text: $viewModel.draft,
                prompt: Text("Type a message...").foregroundColor(AppTheme.placeholder),
                axis: .vertical
            )
            .lineLimit(1...4)
            .font(.system(size: 14))
            .foregroundColor(AppTheme.textPrimary)
            .focused($isInputFocused)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.fieldFill)
            )

            Button {
                viewModel.send(using: chatStore)
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(viewModel.canSend ? AppTheme.brandOrange : AppTheme.border)
                    )
            }
            .disabled(!viewModel.canSend)
            .animation(.easeOut(duration: 0.15), value: viewModel.canSend)
            .accessibilityLabel("Send")
        }
    }

    private var blockedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "nosign")
                .foregroundColor(AppTheme.requiredRed)
            Text("You blocked \(partner?.name ?? "this user"). You can't send messages in this chat.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.requiredRed.opacity(0.06))
        )
    }

    private var reportButton: some View {
        Button {
            viewModel.isShowingReportOptions = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isReported ? "checkmark.circle" : "flag")
                Text(isReported ? "Reported" : "Report")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isReported)
    }

    private var blockButton: some View {
        Button {
            if isBlocked {
                partner.map { chatStore.unblock($0.id) }
            } else {
                viewModel.isShowingBlockConfirmation = true
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isBlocked ? "person.crop.circle.badge.checkmark" : "nosign")
                Text(isBlocked ? "Unblock" : "Block")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppTheme.requiredRed)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.requiredRed.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.requiredRed.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(partner == nil)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatView(conversationId: "listing-1")
                .withAppRoutes()
        }
        .environmentObject(ListingStore())
        .environmentObject(ChatStore())
    }
}
