import SwiftUI

struct CartView: View {
    @ObservedObject var cart: CartStore
    @ObservedObject var listingStore: ListingStore
    var onBrowse: () -> Void
    var onContactSellers: () -> Void = {}

    private var cartItems: [ListingItem] {
        cart.items(from: listingStore.allListings)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Shopping Cart")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                if !cartItems.isEmpty {
                    Button("Clear All") { cart.clear() }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(SwapTheme.orange)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(SwapTheme.cardBackground)

            if cartItems.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "cart")
                        .font(.system(size: 52))
                        .foregroundColor(SwapTheme.orange.opacity(0.6))
                    Text("Your cart is empty")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Button(action: onBrowse) {
                        Text("Browse Listings")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(SwapTheme.orange)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(cartItems) { item in
                            CartRowView(item: item) { cart.remove(item) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("\(cartItems.count) item\(cartItems.count == 1 ? "" : "s")")
                            .foregroundColor(.secondary)
                        Spacer()
                        let total = cart.estimatedTotal(from: listingStore.allListings)
                        if total > 0 {
                            Text("Est. total: $\(Int(total)) NZD")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(SwapTheme.priceRed)
                        }
                    }
                    Button(action: onContactSellers) {
                        Text("Contact Sellers")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
    }
}

struct CartRowView: View {
    let item: ListingItem
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ListingThumbnailView(item: item, cornerRadius: 8)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.system(size: 14, weight: .medium)).lineLimit(2)
                if let price = item.price {
                    Text("$\(Int(price))").font(.system(size: 15, weight: .bold)).foregroundColor(SwapTheme.priceRed)
                } else if item.tradeType == .free {
                    Text("Free").font(.system(size: 15, weight: .bold)).foregroundColor(TradeType.free.color)
                } else {
                    Text("Barter").font(.system(size: 15, weight: .bold)).foregroundColor(TradeType.swap.color)
                }
                CampusBadge(campus: item.campus)
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "trash").foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(SwapTheme.cardBackground)
        .cornerRadius(12)
    }
}
