import SwiftUI

struct ListingCard: View {
    let listing: Listing

    private static let imageAspectRatio: CGFloat = 4 / 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .aspectRatio(Self.imageAspectRatio, contentMode: .fit)
                .overlay {
                    ListingImageView(listing: listing)
                        .allowsHitTesting(false)
                }
                .clipped()
                .contentShape(Rectangle())
                .overlay(alignment: .topLeading) {
                    TradeTypeBadge(type: listing.tradeType)
                        .padding(8)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(listing.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                priceLabel

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.system(size: 12))
                    Text("\(listing.campus.displayName) · \(Self.distanceText(listing.distanceKm))")
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                .foregroundColor(AppTheme.textTertiary)

                Spacer(minLength: 0)

                HStack {
                    Spacer()
                    FavoriteHeartButton(
                        listingId: listing.id,
                        style: .card(displayCount: listing.likeCount)
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 9)
            .padding(.bottom, 9)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 3)
    }

    @ViewBuilder
    private var priceLabel: some View {
        if listing.tradeType == .giveaway {
            Text("Free · Pickup only")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        } else if let price = listing.price {
            Text("$\(Int(price))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.brandOrange)
        } else {
            Text("Open to swap")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
    }

    static func distanceText(_ km: Double) -> String {
        String(format: "%.1f km", km)
    }
}

struct TradeTypeBadge: View {
    let type: TradeType

    var body: some View {
        Text(type.badgeTitle)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(type.badgeColor))
    }
}

struct ListingImageView: View {
    let listing: Listing

    var body: some View {
        if let data = listing.photoData.first, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let url = listing.primaryImageURL {
            AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.2))) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ListingImagePlaceholder(listing: listing)
                case .empty:
                    ListingImagePlaceholder(listing: listing, isLoading: true)
                @unknown default:
                    ListingImagePlaceholder(listing: listing)
                }
            }
        } else if let imageName = listing.imageName, UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            ListingImagePlaceholder(listing: listing)
        }
    }
}

struct ListingImagePlaceholder: View {
    let listing: Listing
    var isLoading = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [listing.category.background, listing.category.background.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if isLoading {
                ProgressView()
                    .tint(listing.category.tint)
            } else {
                Image(systemName: listing.symbolName)
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(listing.category.tint.opacity(0.8))
            }
        }
        .accessibilityHidden(true)
    }
}
