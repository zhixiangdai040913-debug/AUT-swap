import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var favoritesStore: FavoritesStore

    var body: some View {
        Group {
            if !appState.isAuthReady {
                ProgressView("Loading…")
                    .tint(AppTheme.brandOrange)
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
                .tint(AppTheme.textPrimary)
            }
        }
        .task {
            appState.startAuthListeningIfNeeded()
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            appState.markReadyIfStillWaiting()
            await syncFavoritesWithAuth()
        }
        .onChange(of: appState.isAuthenticated) { _ in
            Task { await syncFavoritesWithAuth() }
        }
        .onChange(of: appState.currentUserId) { _ in
            Task { await syncFavoritesWithAuth() }
        }
    }

    private func syncFavoritesWithAuth() async {
        guard appState.isAuthenticated else {
            favoritesStore.clear()
            return
        }
        await favoritesStore.loadFavorites(userId: appState.currentUserId)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppState())
            .environmentObject(ListingStore())
            .environmentObject(FavoritesStore())
            .environmentObject(ChatStore())
    }
}
