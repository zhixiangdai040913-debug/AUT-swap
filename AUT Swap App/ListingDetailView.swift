import SwiftUI

struct ListingDetailView: View {
    let item: ListingItem
    @ObservedObject var cart: CartStore
    var onContactSeller: () -> Void
    var onViewSellerProfile: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            detailHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ListingImageGalleryView(item: item)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 280)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        detailPrice
                        HStack(spacing: 8) {
                            CampusBadge(campus: item.campus)
                            TradeTypeBadge(type: item.tradeType)
                        }
                    }

                    sellerCard

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)
                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("Offline payment only — cash or bank transfer on campus pickup.")
                        .font(.caption)
                        .foregroundColor(SwapTheme.orange)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SwapTheme.orangeLight)
                        .cornerRadius(8)
                }
                .padding(20)
            }

            detailActions
        }
        .frame(minWidth: 440, minHeight: 560)
        .background(SwapTheme.background)
    }

    private var sellerCard: some View {
        Button(action: onViewSellerProfile) {
            HStack(spacing: 12) {
                Circle()
                    .fill(SwapTheme.orangeLight)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(item.sellerName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(SwapTheme.orange)
                    )
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.sellerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    if let score = item.trustScore {
                        Text("⭐ \(String(format: "%.1f", score)) · \(item.sellerListingCount) listings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("New seller · \(item.sellerListingCount) listing\(item.sellerListingCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text("View profile")
                    .font(.caption)
                    .foregroundColor(SwapTheme.orange)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(SwapTheme.cardBackground)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var detailHeader: some View {
        HStack {
            Text("Item Details")
                .font(.headline)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(SwapTheme.cardBackground)
    }

    @ViewBuilder
    private var detailPrice: some View {
        if let price = item.price {
            Text("$\(Int(price)) NZD")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(SwapTheme.priceRed)
        } else if item.tradeType == .free {
            Text("Free Giveaway")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(TradeType.free.color)
        } else {
            Text("Open to Barter")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(TradeType.swap.color)
        }
    }

    private var detailActions: some View {
        VStack(spacing: 10) {
            Button(action: { cart.toggle(item) }) {
                HStack {
                    Image(systemName: cart.contains(item) ? "cart.fill" : "plus.circle.fill")
                    Text(cart.contains(item) ? "Remove from Cart" : "Add to Cart")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(SwapTheme.orange)
                .background(SwapTheme.orangeLight)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(SwapTheme.orange, lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onContactSeller) {
                HStack {
                    Image(systemName: "bubble.left.fill")
                    Text("Contact Seller")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(SwapTheme.orange)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(SwapTheme.cardBackground)
    }
}
