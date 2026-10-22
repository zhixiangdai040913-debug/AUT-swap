import SwiftUI

@main
struct UniversitySwapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
        var delegate
    @StateObject private var appState = AppState()
    @StateObject private var listingStore = ListingStore(
        seed: AppConfig.useSampleData ? MockListings.all : []
    )
    @StateObject private var favoritesStore = FavoritesStore()
    @StateObject private var chatStore = ChatStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(listingStore)
                .environmentObject(favoritesStore)
                .environmentObject(chatStore)
                .onAppear {
                    // AppDelegate has already called FirebaseApp.configure().
                    appState.startAuthListeningIfNeeded()
                }
        }
    }
}
