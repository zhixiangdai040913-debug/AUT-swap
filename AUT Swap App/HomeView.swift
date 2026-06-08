import SwiftUI

// MARK: - AUT Swap Home (post sign-in)

struct HomeView: View {
    let userEmail: String
    var onLogout: () -> Void

    @State private var searchText: String = ""
    @State private var selectedCampus: Campus = CampusStorage.load()
    @State private var filterCampuses: Set<Campus> = FilterStorage.loadCampuses()
    @State private var filterCategories: Set<ListingCategory> = FilterStorage.loadCategories()
    @State private var filterTradeTypes: Set<TradeType> = FilterStorage.loadTradeTypes()
    @State private var selectedSort: SortOption = .latestFirst
    @State private var selectedTab: MainTab = .home
    @State private var bannerIndex: Int = 0
    @State private var showFilterPanel: Bool = false

    private var hasActiveFilters: Bool {
        filterCampuses.count != 1
            || !filterCategories.isEmpty
            || !filterTradeTypes.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab == .home {
                homeContent
            } else {
                placeholderTab
            }

            MainTabBar(selectedTab: $selectedTab) { tab in
                handleTabSelect(tab)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
    }

    private var homeContent: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                mainHomeColumn
                    .frame(width: showFilterPanel ? geometry.size.width * 2.0 / 3.0 : geometry.size.width)

                if showFilterPanel {
                    FilterPanelView(
                        selectedCampuses: $filterCampuses,
                        selectedCategories: $filterCategories,
                        selectedTradeTypes: $filterTradeTypes,
                        resultCount: filteredListings.count,
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

    private var mainHomeColumn: some View {
        VStack(spacing: 0) {
            HomeTopBar(
                hasActiveFilters: hasActiveFilters,
                onFilter: { showFilterPanel.toggle() },
                onNotifications: { /* TODO: FR5 */ },
                onProfile: { /* TODO: FR6 */ }
            )

            ActiveFilterChipsBar(
                campuses: filterCampuses,
                categories: filterCategories,
                tradeTypes: filterTradeTypes,
                onRemoveCampus: { campus in
                    filterCampuses.remove(campus)
                    if filterCampuses.isEmpty {
                        filterCampuses = [selectedCampus]
                    }
                    syncSelectedCampusFromFilters()
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

            ScrollView {
                VStack(spacing: 14) {
                    HomeSearchBar(searchText: $searchText)

                    CampusPickerBar(
                        activeCampuses: filterCampuses,
                        selectedCampus: $selectedCampus,
                        onCampusChange: { campus in
                            filterCampuses = [campus]
                            CampusStorage.save(campus)
                            persistFilters()
                        }
                    )

                    CategoryScrollBar(
                        selectedCategory: singleCategoryBinding,
                        onCategoryTap: { category in
                            if let category = category {
                                toggleCategory(category)
                            } else {
                                filterCategories.removeAll()
                                persistFilters()
                            }
                        }
                    )

                    PromoBannerView(
                        title: MockData.promoBanners[bannerIndex].title,
                        subtitle: MockData.promoBanners[bannerIndex].subtitle
                    )
                    .onTapGesture {
                        bannerIndex = (bannerIndex + 1) % MockData.promoBanners.count
                    }

                    SortBar(
                        selectedSort: $selectedSort,
                        onSortChange: { _ in }
                    )

                    if filteredListings.isEmpty {
                        NoResultsView()
                    } else {
                        ProductGridView(items: filteredListings) { _ in
                            /* TODO: FR5 chat */
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
    }

    /// Sync horizontal category bar when exactly one category is selected in the filter set.
    private var singleCategoryBinding: Binding<ListingCategory?> {
        Binding(
            get: {
                filterCategories.count == 1 ? filterCategories.first : nil
            },
            set: { newValue in
                if let category = newValue {
                    filterCategories = [category]
                } else {
                    filterCategories.removeAll()
                }
                persistFilters()
            }
        )
    }

    private var filteredListings: [ListingItem] {
        var items = MockData.listings

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            items = items.filter { $0.title.lowercased().contains(query) }
        }

        items = items.filter { filterCampuses.contains($0.campus) }

        if !filterCategories.isEmpty {
            items = items.filter { filterCategories.contains($0.category) }
        }

        if !filterTradeTypes.isEmpty {
            items = items.filter { filterTradeTypes.contains($0.tradeType) }
        }

        switch selectedSort {
        case .latestFirst:
            items.sort { $0.postedAt > $1.postedAt }
        case .priceLowHigh:
            items.sort { priceSortValue($0) < priceSortValue($1) }
        }

        return items
    }

    private func priceSortValue(_ item: ListingItem) -> Double {
        if let price = item.price { return price }
        if item.tradeType == .free { return 0 }
        return 999_999
    }

    private func toggleCampus(_ campus: Campus) {
        if filterCampuses.contains(campus) {
            if filterCampuses.count > 1 {
                filterCampuses.remove(campus)
            }
        } else {
            filterCampuses.insert(campus)
        }
        if filterCampuses.count == 1 {
            syncSelectedCampusFromFilters()
        }
        persistFilters()
    }

    private func syncSelectedCampusFromFilters() {
        if filterCampuses.count == 1, let campus = filterCampuses.first {
            selectedCampus = campus
            CampusStorage.save(campus)
        }
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
        filterCampuses = [selectedCampus]
        filterCategories.removeAll()
        filterTradeTypes.removeAll()
        persistFilters()
    }

    private func persistFilters() {
        FilterStorage.saveCampuses(filterCampuses)
        FilterStorage.saveCategories(filterCategories)
        FilterStorage.saveTradeTypes(filterTradeTypes)
    }

    private var placeholderTab: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: selectedTab.iconName)
                .font(.system(size: 48))
                .foregroundColor(SwapTheme.orange)
            Text(selectedTab.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
            Text("Coming soon")
                .foregroundColor(.secondary)
            if selectedTab == .profile {
                Text("Signed in as \(userEmail)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(action: onLogout) {
                    Text("Log Out")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(SwapTheme.orange)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
    }

    private func handleTabSelect(_ tab: MainTab) {
        if tab != .home {
            showFilterPanel = false
        }
    }
}
