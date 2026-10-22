import SwiftUI

/// Reusable favorite (收藏) control bound to `FavoritesStore`.
struct FavoriteHeartButton: View {
    enum Style {
        /// Compact heart used on listing cards (optional count label).
        case card(displayCount: Int)
        /// Larger toolbar / detail heart.
        case detail
    }

    let listingId: String
    var style: Style = .detail

    @EnvironmentObject private var favoritesStore: FavoritesStore
    @EnvironmentObject private var appState: AppState

    @State private var showSignInPrompt = false
    @State private var errorMessage: String?

    private var isFavorited: Bool {
        favoritesStore.isFavorited(listingId)
    }

    private var isBusy: Bool {
        favoritesStore.isToggling(listingId)
    }

    var body: some View {
        Button {
            Task { await toggle() }
        } label: {
            labelContent
        }
        .buttonStyle(.borderless)
        .disabled(isBusy)
        .opacity(isBusy ? 0.55 : 1)
        .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
        .alert("Sign in required", isPresented: $showSignInPrompt) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please sign in with your AUT email to save favorites.")
        }
        .alert(
            "Couldn't update favorite",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var labelContent: some View {
        switch style {
        case .card(let displayCount):
            HStack(spacing: 3) {
                heartImage(size: 12)
                Text("\(displayCount)")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
            }
        case .detail:
            heartImage(size: 18)
                .frame(width: 28, height: 28)
        }
    }

    private func heartImage(size: CGFloat) -> some View {
        Image(systemName: isFavorited ? "heart.fill" : "heart")
            .font(.system(size: size, weight: .medium))
            .foregroundColor(isFavorited ? AppTheme.brandOrange : AppTheme.textTertiary)
    }

    private func toggle() async {
        let signedIn = appState.isAuthenticated || appState.currentUserId != nil
        let result = await favoritesStore.toggleFavorite(
            listingId: listingId,
            userId: appState.currentUserId,
            isAuthenticated: signedIn
        )
        switch result {
        case .success, .ignoredBusy:
            break
        case .needsSignIn:
            showSignInPrompt = true
        case .failure(let message):
            errorMessage = message
        }
    }
}
