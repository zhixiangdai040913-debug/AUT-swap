import SwiftUI

struct HomeView: View {
    let userEmail: String
    @ObservedObject var cart: CartStore
    @ObservedObject var listingStore: ListingStore
    @ObservedObject var messageStore: MessageStore
    var onLogout: () -> Void

    @State private var searchText = ""
    @State private var selectedFeedTab: HomeFeedTab = .recommended
    @State private var categorySort: CategorySortOption = .campus
    @State private var preferredCampus: Campus = CampusStorage.load()
    @State private var filterCampuses: Set<Campus> = FilterStorage.loadCampuses()
    @State private var filterCategories: Set<ListingCategory> = FilterStorage.loadCategories()
    @State private var filterTradeTypes: Set<TradeType> = FilterStorage.loadTradeTypes()
    @State private var showFilterPanel = false
    @State private var selectedTab: MainTab = .home
    @State private var selectedListing: ListingItem?
    @State private var sellerProfileEmail: String?
    @State private var sellerProfileName: String?
    @State private var selectedConversationId: String?

    private var hasActiveFilters: Bool {
        filterCampuses.count != 1
            || !filterCategories.isEmpty
            || !filterTradeTypes.isEmpty
    }

    private var displayListings: [ListingItem] {
        var items = listingStore.listings(for: selectedFeedTab, search: searchText)
        items = listingStore.applyFilters(
            items,
            campuses: filterCampuses,
            categories: filterCategories,
            tradeTypes: filterTradeTypes
        )
        return listingStore.sorted(items, by: categorySort, preferredCampus: preferredCampus)
    }

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                homeFeed
            case .cart:
                CartView(
                    cart: cart,
                    listingStore: listingStore,
                    onBrowse: { selectedTab = .home },
                    onContactSellers: contactCartSellers
                )
            case .messages:
                MessagesView(
                    messageStore: messageStore,
                    selectedConversationId: $selectedConversationId
                )
            case .post:
                PostListingView(
                    listingStore: listingStore,
                    sellerName: ProfileStorage.loadDisplayName(for: userEmail)
                        ?? ProfileView.nameFromEmail(userEmail),
                    sellerEmail: userEmail,
                    onPublished: { selectedTab = .home }
                )
            case .profile:
                ProfileView(
                    userEmail: userEmail,
                    listingStore: listingStore,
                    cart: cart,
                    messageStore: messageStore,
                    onLogout: onLogout,
                    onBrowse: { selectedTab = .home },
                    onPost: { selectedTab = .post },
                    onOpenMessages: { selectedTab = .messages },
                    onSelectListing: { item in selectedListing = item }
                )
            }

            MainTabBar(
                selectedTab: $selectedTab,
                cartCount: cart.count,
                messageUnreadCount: messageStore.unreadTotal
            ) { tab in
                if tab != .home { showFilterPanel = false }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
        .sheet(item: $selectedListing) { listing in
            ListingDetailView(
                item: listing,
                cart: cart,
                onContactSeller: {
                    openChat(with: listing)
                },
                onViewSellerProfile: {
                    sellerProfileEmail = listing.sellerEmail
                    sellerProfileName = listing.sellerName
                },
                onClose: { selectedListing = nil }
            )
        }
        .sheet(isPresented: Binding(
            get: { sellerProfileEmail != nil },
            set: { if !$0 { sellerProfileEmail = nil; sellerProfileName = nil } }
        )) {
            if let email = sellerProfileEmail, let name = sellerProfileName {
                SellerProfileView(
                    sellerEmail: email,
                    sellerName: name,
                    listingStore: listingStore,
                    cart: cart,
                    onClose: { sellerProfileEmail = nil; sellerProfileName = nil },
                    onSelectListing: { item in
                        sellerProfileEmail = nil
                        sellerProfileName = nil
                        selectedListing = item
                    },
                    onMessageSeller: {
                        let listing = listingStore.listingsBySeller(email).first
                        let id = messageStore.startConversation(
                            withSellerName: name,
                            sellerEmail: email,
                            listing: listing,
                            openingNote: "Hi \(name.split(separator: " ").first.map(String.init) ?? name) — I'd like to chat about your listings."
                        )
                        sellerProfileEmail = nil
                        sellerProfileName = nil
                        selectedConversationId = id
                        selectedTab = .messages
                    }
                )
            }
        }
    }

    private var homeFeed: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HomeTopBar(
                        hasActiveFilters: hasActiveFilters,
                        cartCount: cart.count,
                        onFilter: { showFilterPanel.toggle() },
                        onCart: { selectedTab = .cart },
                        onProfile: { selectedTab = .profile }
                    )

                    ActiveFilterChipsBar(
                        campuses: filterCampuses,
                        categories: filterCategories,
                        tradeTypes: filterTradeTypes,
                        onRemoveCampus: { campus in
                            filterCampuses.remove(campus)
                            if filterCampuses.isEmpty {
                                filterCampuses = [preferredCampus]
                            }
                            persistFilters()
                        },
                        onRemoveCategory: { category in
                            filterCategories.remove(category)
                            persistFilters()
                        },
                        onRemoveTradeType: { type in
                            filterTradeTypes.remove(type)
                            persistFilters()
                        }
                    )

                    HomeSearchBar(searchText: $searchText)

                    FeedCategoryTabBar(selectedTab: $selectedFeedTab)

                    CategorySortBar(selectedSort: $categorySort)

                    HStack(spacing: 8) {
                        Text("Campus priority:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(Campus.allCases) { campus in
                            Button(action: {
                                preferredCampus = campus
                                CampusStorage.save(campus)
                            }) {
                                Text(campus.rawValue)
                                    .font(.caption)
                                    .fontWeight(preferredCampus == campus ? .semibold : .regular)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(preferredCampus == campus ? SwapTheme.orange : Color(white: 0.94))
                                    .foregroundColor(preferredCampus == campus ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                    ScrollView {
                        if displayListings.isEmpty {
                            NoResultsView()
                        } else {
                            ProductGridView(items: displayListings, cart: cart) { item in
                                selectedListing = item
                            }
                        }
                    }
                }
                .frame(width: showFilterPanel ? geometry.size.width * 2.0 / 3.0 : geometry.size.width)

                if showFilterPanel {
                    FilterPanelView(
                        selectedCampuses: $filterCampuses,
                        selectedCategories: $filterCategories,
                        selectedTradeTypes: $filterTradeTypes,
                        listings: listingStore.allListings,
                        resultCount: displayListings.count,
                        onClose: { showFilterPanel = false },
                        onClearAll: clearAllFilters,
                        onToggleCampus: toggleCampus,
                        onToggleCategory: toggleCategory,
                        onToggleTradeType: toggleTradeType
                    )
                    .frame(width: geometry.size.width / 3.0)
                }
            }
        }
    }

    private func openChat(with listing: ListingItem) {
        let note = "Hi \(listing.sellerName.split(separator: " ").first.map(String.init) ?? listing.sellerName) — I'm interested in \"\(listing.title)\"."
        let id = messageStore.startConversation(
            withSellerName: listing.sellerName,
            sellerEmail: listing.sellerEmail,
            listing: listing,
            openingNote: note
        )
        selectedListing = nil
        selectedConversationId = id
        selectedTab = .messages
    }

    private func contactCartSellers() {
        let items = cart.items(from: listingStore.allListings)
        var lastId: String?
        var seen = Set<String>()
        for item in items {
            let key = "\(item.sellerEmail.lowercased())|\(item.id)"
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            lastId = messageStore.startConversation(
                withSellerName: item.sellerName,
                sellerEmail: item.sellerEmail,
                listing: item,
                openingNote: "Hi — I'm interested in \"\(item.title)\" from my cart."
            )
        }
        if let lastId = lastId {
            selectedConversationId = lastId
        }
        selectedTab = .messages
    }

    private func toggleCampus(_ campus: Campus) {
        if filterCampuses.contains(campus) {
            if filterCampuses.count > 1 {
                filterCampuses.remove(campus)
            }
        } else {
            filterCampuses.insert(campus)
        }
        if filterCampuses.count == 1, let only = filterCampuses.first {
            preferredCampus = only
            CampusStorage.save(only)
        }
        persistFilters()
    }

    private func toggleCategory(_ category: ListingCategory) {
        if filterCategories.contains(category) {
            filterCategories.remove(category)
        } else {
            filterCategories.insert(category)
        }
        persistFilters()
    }

    private func toggleTradeType(_ type: TradeType) {
        if filterTradeTypes.contains(type) {
            filterTradeTypes.remove(type)
        } else {
            filterTradeTypes.insert(type)
        }
        persistFilters()
    }

    private func clearAllFilters() {
        filterCampuses = [preferredCampus]
        filterCategories.removeAll()
        filterTradeTypes.removeAll()
        persistFilters()
    }

    private func persistFilters() {
        FilterStorage.saveCampuses(filterCampuses)
        FilterStorage.saveCategories(filterCategories)
        FilterStorage.saveTradeTypes(filterTradeTypes)
    }
}
