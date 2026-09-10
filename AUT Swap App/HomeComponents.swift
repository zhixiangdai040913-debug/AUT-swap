import SwiftUI

// MARK: - Theme

enum SwapTheme {
    static let orange = Color(red: 245 / 255, green: 130 / 255, blue: 32 / 255)
    static let orangeLight = Color(red: 255 / 255, green: 245 / 255, blue: 235 / 255)
    static let background = Color(red: 248 / 255, green: 248 / 255, blue: 250 / 255)
    static let cardBackground = Color.white
    static let priceRed = Color(red: 220 / 255, green: 50 / 255, blue: 40 / 255)
}

// MARK: - Top Bar

struct HomeTopBar: View {
    var hasActiveFilters: Bool
    var cartCount: Int
    var onFilter: () -> Void
    var onCart: () -> Void
    var onProfile: () -> Void

    private let logoSize: CGFloat = 36

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("AUT Swap")
                .font(.system(size: 22, weight: .bold))
            Spacer()

            Button(action: onFilter) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundColor(SwapTheme.orange)
                    if hasActiveFilters {
                        Circle()
                            .fill(SwapTheme.priceRed)
                            .frame(width: 8, height: 8)
                            .offset(x: 6, y: -4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onCart) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(SwapTheme.orange)
                    if cartCount > 0 {
                        Text("\(min(cartCount, 99))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(SwapTheme.priceRed)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            Button(action: onProfile) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(SwapTheme.orange)
            }
            .buttonStyle(PlainButtonStyle())
            AUTLogoMark(size: logoSize)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(SwapTheme.cardBackground)
    }
}

// MARK: - Feed category tabs (Xianyu-style)

struct FeedCategoryTabBar: View {
    @Binding var selectedTab: HomeFeedTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(HomeFeedTab.allTabs) { tab in
                    let isSelected = selectedTab == tab
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 6) {
                            Text(tab.title)
                                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? SwapTheme.orange : .secondary)
                            Rectangle()
                                .fill(isSelected ? SwapTheme.orange : Color.clear)
                                .frame(height: 2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
        }
        .background(SwapTheme.cardBackground)
    }
}

// MARK: - Category sort (price / campus)

struct CategorySortBar: View {
    @Binding var selectedSort: CategorySortOption

    var body: some View {
        HStack(spacing: 8) {
            Text("Sort by:")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            ForEach(CategorySortOption.allCases) { option in
                Button(action: { selectedSort = option }) {
                    Text(option.rawValue)
                        .font(.system(size: 13, weight: selectedSort == option ? .semibold : .regular))
                        .foregroundColor(selectedSort == option ? SwapTheme.orange : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedSort == option ? SwapTheme.orangeLight : Color(white: 0.96))
                        .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

// MARK: - Search Bar

struct HomeSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search textbooks, furniture, electronics...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(white: 0.96))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(SwapTheme.orange.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Active filter chips

struct ActiveFilterChipsBar: View {
    let campuses: Set<Campus>
    let categories: Set<ListingCategory>
    let tradeTypes: Set<TradeType>
    var onRemoveCampus: (Campus) -> Void
    var onRemoveCategory: (ListingCategory) -> Void
    var onRemoveTradeType: (TradeType) -> Void

    private var hasChips: Bool {
        campuses.count > 1 || !categories.isEmpty || !tradeTypes.isEmpty
    }

    var body: some View {
        if hasChips {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Campus.allCases.filter { campuses.contains($0) }) { campus in
                        if campuses.count > 1 {
                            FilterChip(title: campus.rawValue) { onRemoveCampus(campus) }
                        }
                    }
                    ForEach(Array(categories).sorted { $0.rawValue < $1.rawValue }) { category in
                        FilterChip(title: category.rawValue) { onRemoveCategory(category) }
                    }
                    ForEach(Array(tradeTypes).sorted { $0.rawValue < $1.rawValue }) { type in
                        FilterChip(title: type.filterLabel) { onRemoveTradeType(type) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .background(SwapTheme.cardBackground)
        }
    }
}

struct FilterChip: View {
    let title: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(SwapTheme.orangeLight)
        .foregroundColor(SwapTheme.orange)
        .cornerRadius(14)
    }
}

// MARK: - Filter panel

struct FilterPanelView: View {
    @Binding var selectedCampuses: Set<Campus>
    @Binding var selectedCategories: Set<ListingCategory>
    @Binding var selectedTradeTypes: Set<TradeType>
    let listings: [ListingItem]
    let resultCount: Int
    var onClose: () -> Void
    var onClearAll: () -> Void
    var onToggleCampus: (Campus) -> Void
    var onToggleCategory: (ListingCategory) -> Void
    var onToggleTradeType: (TradeType) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All", action: onClearAll)
                    .font(.caption)
                    .foregroundColor(SwapTheme.orange)
                    .buttonStyle(PlainButtonStyle())
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SwapTheme.cardBackground)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    filterSection("Campus") {
                        ForEach(Campus.allCases) { campus in
                            filterRow(
                                title: campus.rawValue,
                                count: ListingCounts.campusCount(campus, in: listings),
                                isSelected: selectedCampuses.contains(campus)
                            ) {
                                onToggleCampus(campus)
                            }
                        }
                    }

                    filterSection("Category") {
                        ForEach(ListingCategory.allCases) { category in
                            filterRow(
                                title: category.rawValue,
                                count: ListingCounts.categoryCount(category, campuses: selectedCampuses, in: listings),
                                isSelected: selectedCategories.contains(category)
                            ) {
                                onToggleCategory(category)
                            }
                        }
                    }

                    filterSection("Transaction Type") {
                        ForEach(TradeType.allCases) { type in
                            filterRow(
                                title: type.filterLabel,
                                count: ListingCounts.tradeTypeCount(type, campuses: selectedCampuses, in: listings),
                                isSelected: selectedTradeTypes.contains(type)
                            ) {
                                onToggleTradeType(type)
                            }
                        }
                    }
                }
                .padding(16)
            }

            Text("\(resultCount) result\(resultCount == 1 ? "" : "s")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SwapTheme.orange)
                .foregroundColor(.white)
        }
        .background(Color(white: 0.97))
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1),
            alignment: .leading
        )
    }

    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            content()
        }
    }

    private func filterRow(title: String, count: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? SwapTheme.orange : .secondary)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Listing Card

struct ListingCardView: View {
    let item: ListingItem
    var isInCart: Bool
    var onTap: () -> Void
    var onAddToCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ListingThumbnailView(item: item, cornerRadius: 8)
                    .onTapGesture(perform: onTap)

                Button(action: onAddToCart) {
                    Image(systemName: isInCart ? "cart.fill" : "plus.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isInCart ? .white : SwapTheme.orange)
                        .padding(6)
                        .background(isInCart ? SwapTheme.orange : Color.white.opacity(0.95))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(height: 28, alignment: .topLeading)
                priceLabel
                CampusBadge(campus: item.campus)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
        }
        .background(SwapTheme.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var priceLabel: some View {
        if let price = item.price {
            Text("$\(Int(price))")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(item.tradeType == .sell ? SwapTheme.priceRed : SwapTheme.orange)
        } else if item.tradeType == .free {
            Text("Free")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(TradeType.free.color)
        } else {
            Text("Barter")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(TradeType.swap.color)
        }
    }
}

struct TradeTypeBadge: View {
    let type: TradeType

    var body: some View {
        Text(type.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(type.color)
            .cornerRadius(4)
    }
}

struct CampusBadge: View {
    let campus: Campus

    var body: some View {
        Text(campus.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color(white: 0.94))
            .cornerRadius(4)
    }
}

// MARK: - Product Grid

struct ProductGridView: View {
    let items: [ListingItem]
    var cart: CartStore
    var onSelect: (ListingItem) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items) { item in
                ListingCardView(
                    item: item,
                    isInCart: cart.contains(item),
                    onTap: { onSelect(item) },
                    onAddToCart: { cart.toggle(item) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Tab Bar

struct MainTabBar: View {
    @Binding var selectedTab: MainTab
    var cartCount: Int
    var messageUnreadCount: Int = 0
    var onTabSelect: (MainTab) -> Void

    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { tab in
                Button(action: {
                    selectedTab = tab
                    onTabSelect(tab)
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20))
                            if tab == .cart && cartCount > 0 {
                                Text("\(min(cartCount, 99))")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(SwapTheme.priceRed)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -8)
                            } else if tab == .messages && messageUnreadCount > 0 {
                                Text("\(min(messageUnreadCount, 99))")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(SwapTheme.priceRed)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -8)
                            }
                        }
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    }
                    .foregroundColor(selectedTab == tab ? SwapTheme.orange : .secondary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(SwapTheme.cardBackground)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Empty results

struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No results")
                .font(.system(size: 17, weight: .semibold))
            Text("Try adjusting your filters or search terms.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
    }
}
