import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject private var listingStore: ListingStore
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @StateObject private var viewModel: ListingDetailViewModel

    private let horizontalPadding: CGFloat = 16

    init(listingId: String) {
        _viewModel = StateObject(wrappedValue: ListingDetailViewModel(listingId: listingId))
    }

    var body: some View {
        Group {
            if let listing = listingStore.listing(id: viewModel.listingId) {
                content(for: listing)
            } else {
                PlaceholderContent(title: "Listing not found", systemImage: "exclamationmark.magnifyingglass")
            }
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar { toolbarContent }
    }

    // MARK: - Content

    private func content(for listing: Listing) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                gallery(for: listing)
                    .padding(.horizontal, 6)

                VStack(alignment: .leading, spacing: 0) {
                    summary(for: listing)

                    sectionDivider

                    sellerRow(for: listing)

                    sectionDivider

                    descriptionSection(listing.description)

                    sectionDivider

                    infoRow(icon: "mappin", title: "Pickup", subtitle: listing.pickupNote)

                    sectionDivider

                    infoRow(icon: "banknote", title: "Payment", subtitle: ListingDetailViewModel.paymentMethod)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 16)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            NavigationLink(value: AppRoute.chat(conversationId: viewModel.conversationId)) {
                Text("Chat")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Capsule().fill(AppTheme.brandOrange))
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Color.white)
        }
    }

    private func summary(for listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(listing.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 16)

            priceLabel(for: listing)
                .padding(.top, 6)

            Text(listing.condition)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.top, 6)

            HStack(spacing: 5) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 13))
                Text("\(listing.campus.displayName) · \(ListingCard.distanceText(listing.distanceKm))")
                    .font(.system(size: 13))
            }
            .foregroundColor(AppTheme.textTertiary)
            .padding(.top, 8)

            tags(listing.tags)
                .padding(.top, 12)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            FavoriteHeartButton(listingId: viewModel.listingId, style: .detail)
            ShareLink(item: viewModel.shareText(for: listingStore.listing(id: viewModel.listingId))) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
            }
            Menu {
                Button(role: .destructive) {} label: {
                    Label("Report Listing", systemImage: "flag")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 28, height: 28)
            }
            .accessibilityLabel("More")
        }
    }

    // MARK: - Gallery

    private func gallery(for listing: Listing) -> some View {
        let pageCount = galleryPageCount(for: listing)
        return TabView(selection: $viewModel.selectedPhotoIndex) {
            ForEach(0..<pageCount, id: \.self) { index in
                photoPage(for: listing, index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topLeading) {
            TradeTypeBadge(type: listing.tradeType)
                .padding(12)
        }
        .overlay(alignment: .bottom) {
            if pageCount > 1 {
                pageDots(count: pageCount, selected: viewModel.selectedPhotoIndex)
                    .padding(.bottom, 10)
            }
        }
    }

    private func galleryPageCount(for listing: Listing) -> Int {
        if !listing.photoData.isEmpty { return listing.photoData.count }
        if !listing.imageURLs.isEmpty { return listing.imageURLs.count }
        if listing.primaryImageURL != nil { return 1 }
        if listing.imageName != nil { return 1 }
        return max(listing.photoSymbols.count, 1)
    }

    @ViewBuilder
    private func photoPage(for listing: Listing, index: Int) -> some View {
        if index < listing.photoData.count, let image = UIImage(data: listing.photoData[index]) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if index < listing.imageURLs.count {
            AsyncImage(url: listing.imageURLs[index]) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ProgressView().tint(listing.category.tint)
                default:
                    ListingImagePlaceholder(listing: listing)
                }
            }
        } else if let url = listing.primaryImageURL, index == 0 {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    ProgressView().tint(listing.category.tint)
                default:
                    ListingImagePlaceholder(listing: listing)
                }
            }
        } else if let imageName = listing.imageName, UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [listing.category.background, listing.category.background.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: listing.photoSymbols[min(index, listing.photoSymbols.count - 1)])
                    .font(.system(size: 72, weight: .regular))
                    .foregroundColor(listing.category.tint.opacity(0.8))
            }
        }
    }

    private func pageDots(count: Int, selected: Int) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(index == selected ? 1 : 0.6))
                    .frame(width: index == selected ? 7 : 5, height: index == selected ? 7 : 5)
            }
        }
        .animation(.easeOut(duration: 0.2), value: selected)
        .accessibilityHidden(true)
    }

    // MARK: - Summary

    @ViewBuilder
    private func priceLabel(for listing: Listing) -> some View {
        if listing.tradeType == .giveaway {
            Text("Free")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.giveawayGreen)
        } else if let price = listing.price {
            Text("$\(Int(price))")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.brandOrange)
        } else {
            Text("Open to swap")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.brandOrange)
        }
    }

    private func tags(_ tags: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal, 14)
                    .frame(height: 30)
                    .background(Capsule().fill(AppTheme.fieldFill))
            }
        }
    }

    // MARK: - Seller

    private func sellerRow(for listing: Listing) -> some View {
        let seller = listing.seller
        return HStack(spacing: 12) {
            NavigationLink(value: AppRoute.trustworthiness(userId: seller.id)) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(listing.category.background)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Text(seller.initials)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(listing.category.tint)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(seller.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        if seller.isVerifiedStudent {
                            HStack(spacing: 4) {
                                Text("AUT Student")
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                            }
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.verifiedBlue)
                        } else {
                            Text("Unverified")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textTertiary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.starYellow)
                            Text("\(String(format: "%.1f", seller.rating)) (\(seller.reviewCount) reviews)")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows trustworthiness score and reviews")

            Spacer()

            NavigationLink(value: AppRoute.chat(conversationId: viewModel.conversationId)) {
                Text("Chat")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.brandOrange)
                    .padding(.horizontal, 24)
                    .frame(height: 36)
                    .overlay(Capsule().stroke(AppTheme.brandOrange, lineWidth: 1.2))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Details

    private func descriptionSection(_ text: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.isDescriptionExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Description")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.icon)
                        .rotationEffect(.degrees(viewModel.isDescriptionExpanded ? 90 : 0))
                }
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(viewModel.isDescriptionExpanded ? nil : 3)
                    .multilineTextAlignment(.leading)
            }
        }
        .buttonStyle(.plain)
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(AppTheme.fieldFill)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.icon)
        }
        .accessibilityElement(children: .combine)
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(AppTheme.divider)
            .padding(.vertical, 12)
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListingDetailView(listingId: "1")
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
        .environmentObject(ChatStore())
    }
}
