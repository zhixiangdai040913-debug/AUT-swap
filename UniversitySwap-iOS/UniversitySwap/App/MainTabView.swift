import SwiftUI
import UIKit

enum MainTab: Hashable {
    case home
    case categories
    case messages
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var homePath = NavigationPath()
    @State private var categoriesPath = NavigationPath()
    @State private var messagesPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    @State private var isShowingCreateListing = false

    init() {
        UITabBar.appearance().isHidden = true
    }

    private var isShowingPushedScreen: Bool {
        switch selectedTab {
        case .home: return !homePath.isEmpty
        case .categories: return !categoriesPath.isEmpty
        case .messages: return !messagesPath.isEmpty
        case .profile: return !profilePath.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabs
            if !isShowingPushedScreen {
                MainTabBar(selectedTab: $selectedTab) {
                    isShowingCreateListing = true
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateListing) {
            NavigationStack {
                CreateListingView(
                    onClose: { isShowingCreateListing = false },
                    onPosted: { _ in
                        isShowingCreateListing = false
                        selectedTab = .home
                    }
                )
            }
            .tint(AppTheme.textPrimary)
        }
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView()
                    .withAppRoutes()
            }
            .tag(MainTab.home)

            NavigationStack(path: $categoriesPath) {
                CategoriesView()
                    .withAppRoutes()
            }
            .tag(MainTab.categories)

            NavigationStack(path: $messagesPath) {
                MessagesView()
                    .withAppRoutes()
            }
            .tag(MainTab.messages)

            NavigationStack(path: $profilePath) {
                ProfileView(onOpenMessages: { selectedTab = .messages })
                    .withAppRoutes()
            }
            .tag(MainTab.profile)
        }
        .tint(AppTheme.textPrimary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
            .environmentObject(ListingStore())
            .environmentObject(ChatStore())
    }
}
