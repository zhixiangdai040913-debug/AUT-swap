import SwiftUI

struct SellerProfileView: View {
    let sellerEmail: String
    let sellerName: String
    @ObservedObject var listingStore: ListingStore
    @ObservedObject var cart: CartStore
    var onClose: () -> Void
    var onSelectListing: (ListingItem) -> Void
    var onMessageSeller: (() -> Void)? = nil

    private var sellerListings: [ListingItem] {
        listingStore.listingsBySeller(sellerEmail)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Seller Profile")
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

            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(SwapTheme.orangeLight)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Text(String(sellerName.prefix(1)))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(SwapTheme.orange)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sellerName)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(sellerEmail)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(sellerListings.count) active listing\(sellerListings.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(SwapTheme.orange)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(SwapTheme.cardBackground)
                    .cornerRadius(12)

                    if let onMessageSeller = onMessageSeller {
                        Button(action: onMessageSeller) {
                            HStack {
                                Image(systemName: "bubble.left.fill")
                                Text("Message Seller")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(SwapTheme.orange)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Text("Other listings from this seller")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ProductGridView(items: sellerListings, cart: cart, onSelect: onSelectListing)
                }
                .padding(20)
            }
        }
        .frame(minWidth: 480, minHeight: 520)
        .background(SwapTheme.background)
    }
}
