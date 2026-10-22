import SwiftUI

/// Listings owned by the signed-in user from the in-memory / Firestore-backed `ListingStore`.
struct MyListingsView: View {
    @EnvironmentObject private var listingStore: ListingStore
    @EnvironmentObject private var appState: AppState

    private let horizontalPadding: CGFloat = 16
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    private var myListings: [Listing] {
        let uid = appState.currentUserId ?? appState.currentSeller.id
        return listingStore.listings.filter { listing in
            listing.seller.id == uid
                || (!listing.sellerUserId.isEmpty && listing.sellerUserId == uid)
        }
    }

    var body: some View {
        Group {
            if myListings.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        if AppConfig.useSampleData {
                            Text("Demo mode — includes sample listings attributed to your account, plus anything you publish in this session.")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textTertiary)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 8)
                        }

                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(myListings) { listing in
                                NavigationLink(value: AppRoute.listingDetail(listingId: listing.id)) {
                                    ListingCard(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationTitle("My Listings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.icon)
            Text("No listings yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Tap + on the tab bar to publish your first item.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
    }
}

struct MyListingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyListingsView()
                .withAppRoutes()
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
    }
}
