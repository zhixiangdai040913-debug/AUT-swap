import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var listingStore: ListingStore
    @StateObject private var viewModel = FavoritesViewModel()

    private let horizontalPadding: CGFloat = 16
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    /// Signed-in for favorites: app session flag, or a sample/Firebase UID is present.
    private var isSignedIn: Bool {
        appState.isAuthenticated || appState.currentUserId != nil
    }

    var body: some View {
        Group {
            if !isSignedIn {
                signInState
            } else if viewModel.isLoading && viewModel.listings.isEmpty {
                loadingState
            } else if let error = viewModel.errorMessage, viewModel.listings.isEmpty {
                errorState(error)
            } else if viewModel.listings.isEmpty {
                emptyState
            } else {
                listingsGrid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .task { await reload() }
        .refreshable { await reload() }
        .onChange(of: favoritesStore.favoriteIDs) { ids in
            viewModel.syncRemovedFavorites(favoriteIDs: ids)
        }
        .onChange(of: appState.isAuthenticated) { _ in
            Task { await reload() }
        }
        .onChange(of: appState.currentUserId) { _ in
            Task { await reload() }
        }
    }

    private var signInState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.icon)
            Text("Sign in to see favorites")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Your saved campus listings appear here after you sign in with your AUT email.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(AppTheme.brandOrange)
            Text("Loading favorites…")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.icon)
            Text("Couldn't load favorites")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button("Try Again") {
                Task { await reload() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(AppTheme.brandOrange)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.icon)
            Text("No favorites yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Tap the heart on a listing to save it here.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            if viewModel.unavailableCount > 0 {
                Text("\(viewModel.unavailableCount) saved item\(viewModel.unavailableCount == 1 ? "" : "s") no longer available.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.top, 4)
            }
        }
    }

    private var listingsGrid: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.unavailableCount > 0 {
                    Text("\(viewModel.unavailableCount) saved item\(viewModel.unavailableCount == 1 ? "" : "s") no longer available.")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 8)
                }

                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.listings) { listing in
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

    private func reload() async {
        await viewModel.load(
            isAuthenticated: isSignedIn,
            userId: appState.currentUserId,
            favoritesStore: favoritesStore,
            listingStore: listingStore
        )
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavoritesView()
                .withAppRoutes()
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
    }
}
