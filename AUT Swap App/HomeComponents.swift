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
    var onFilter: () -> Void
    var onNotifications: () -> Void
    var onProfile: () -> Void

    private let logoSize: CGFloat = 40

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("AUT Swap")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 14) {
                Button(action: onFilter) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
                            .foregroundColor(hasActiveFilters ? SwapTheme.orange : .secondary)
                        if hasActiveFilters {
                            Circle()
                                .fill(SwapTheme.orange)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onNotifications) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(SwapTheme.orange)
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(SwapTheme.cardBackground)
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

// MARK: - Campus Picker

struct CampusPickerBar: View {
    let activeCampuses: Set<Campus>
    @Binding var selectedCampus: Campus
    var onCampusChange: (Campus) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Campus.allCases) { campus in
                let isActive = activeCampuses.contains(campus)
                Button(action: {
                    selectedCampus = campus
                    onCampusChange(campus)
                }) {
                    Text(campus.rawValue)
                        .font(.system(size: 14, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            isActive
                                ? SwapTheme.orange
                                : Color(white: 0.94)
                        )
                        .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Category Scroll

struct CategoryScrollBar: View {
    @Binding var selectedCategory: ListingCategory?
    var onCategoryTap: (ListingCategory?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ListingCategory.allCases) { category in
                    let isSelected = selectedCategory == category
                    Button(action: {
                        if selectedCategory == category {
                            selectedCategory = nil
                            onCategoryTap(nil)
                        } else {
                            selectedCategory = category
                            onCategoryTap(category)
                        }
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? SwapTheme.orange.opacity(0.15) : Color(white: 0.94))
                                    .frame(width: 48, height: 48)
                                Image(systemName: category.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(isSelected ? SwapTheme.orange : .secondary)
                            }
                            Text(category.rawValue)
                                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(isSelected ? SwapTheme.orange : .secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Promo Banner

struct PromoBannerView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.9))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [SwapTheme.orange, Color(red: 210 / 255, green: 100 / 255, blue: 20 / 255)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

// MARK: - Sort Bar

struct SortBar: View {
    @Binding var selectedSort: SortOption
    var onSortChange: (SortOption) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(SortOption.allCases) { option in
                Button(action: {
                    selectedSort = option
                    onSortChange(option)
                }) {
                    Text(option.rawValue)
                        .font(.system(size: 13, weight: selectedSort == option ? .semibold : .regular))
                        .foregroundColor(selectedSort == option ? SwapTheme.orange : .secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            selectedSort == option
                                ? SwapTheme.orangeLight
                                : Color.clear
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    selectedSort == option ? SwapTheme.orange.opacity(0.4) : Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Listing Card

struct ListingCardView: View {
    let item: ListingItem
    var onContact: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(item.imageColor)
                    .frame(height: 130)
                    .overlay(
                        Image(systemName: item.category.iconName)
                            .font(.system(size: 36))
                            .foregroundColor(Color.white.opacity(0.5))
                    )

                Button(action: onContact) {
                    HStack(spacing: 4) {
                        Text("💬")
                            .font(.system(size: 11))
                        Text("Contact")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)

                priceLabel

                HStack(spacing: 6) {
                    TradeTypeBadge(type: item.tradeType)
                    CampusBadge(campus: item.campus)
                }

                trustLabel
            }
            .padding(10)
        }
        .background(SwapTheme.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private var priceLabel: some View {
        if let price = item.price {
            Text("$\(Int(price))")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(item.tradeType == .sell ? SwapTheme.priceRed : SwapTheme.orange)
        } else if item.tradeType == .free {
            Text("Free")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(TradeType.free.color)
        } else {
            Text("Swap")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(TradeType.swap.color)
        }
    }

    @ViewBuilder
    private var trustLabel: some View {
        if item.isNewUser {
            Text("New user")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        } else if let score = item.trustScore {
            Text("⭐ \(String(format: "%.1f", score))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
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
    var onContact: (ListingItem) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                ListingCardView(item: item) {
                    onContact(item)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

// MARK: - Tab Bar

struct MainTabBar: View {
    @Binding var selectedTab: MainTab
    var onTabSelect: (MainTab) -> Void

    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { tab in
                Button(action: {
                    selectedTab = tab
                    onTabSelect(tab)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
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

// MARK: - Active filter chips

struct ActiveFilterChipsBar: View {
    let campuses: Set<Campus>
    let categories: Set<ListingCategory>
    let tradeTypes: Set<TradeType>
    var onRemoveCampus: (Campus) -> Void
    var onRemoveCategory: (ListingCategory) -> Void
    var onRemoveTradeType: (TradeType) -> Void

    var body: some View {
        if campuses.isEmpty && categories.isEmpty && tradeTypes.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(campuses).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { campus in
                        FilterChipView(label: campus.rawValue) {
                            onRemoveCampus(campus)
                        }
                    }
                    ForEach(Array(categories).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                        FilterChipView(label: category.rawValue) {
                            onRemoveCategory(category)
                        }
                    }
                    ForEach(Array(tradeTypes).sorted(by: { $0.filterLabel < $1.filterLabel }), id: \.self) { type in
                        FilterChipView(label: type.filterLabel) {
                            onRemoveTradeType(type)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
            }
        }
    }
}

struct FilterChipView: View {
    let label: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .foregroundColor(SwapTheme.orange)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(SwapTheme.orangeLight)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SwapTheme.orange.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Filter panel (right 1/3)

struct FilterPanelView: View {
    @Binding var selectedCampuses: Set<Campus>
    @Binding var selectedCategories: Set<ListingCategory>
    @Binding var selectedTradeTypes: Set<TradeType>
    let resultCount: Int
    var onClose: () -> Void
    var onClearAll: () -> Void
    var onToggleCampus: (Campus) -> Void
    var onToggleCategory: (ListingCategory) -> Void
    var onToggleTradeType: (TradeType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Filters")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Text("\(resultCount) result\(resultCount == 1 ? "" : "s")")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SwapTheme.orange)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    filterSection(title: "Campus") {
                        ForEach(Campus.allCases) { campus in
                            let count = ListingCounts.campusCount(campus)
                            FilterOptionRow(
                                label: "\(campus.rawValue) (\(count))",
                                isSelected: selectedCampuses.contains(campus),
                                action: { onToggleCampus(campus) }
                            )
                        }
                    }

                    filterSection(title: "Category") {
                        ForEach(ListingCategory.allCases) { category in
                            let count = ListingCounts.categoryCount(category, campuses: selectedCampuses)
                            FilterOptionRow(
                                label: "\(category.rawValue) (\(count))",
                                isSelected: selectedCategories.contains(category),
                                action: { onToggleCategory(category) }
                            )
                        }
                    }

                    filterSection(title: "Transaction Type") {
                        ForEach(TradeType.allCases, id: \.self) { type in
                            let count = ListingCounts.tradeTypeCount(type, campuses: selectedCampuses)
                            FilterOptionRow(
                                label: "\(type.filterLabel) (\(count))",
                                isSelected: selectedTradeTypes.contains(type),
                                action: { onToggleTradeType(type) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            Button(action: onClearAll) {
                Text("Clear all filters")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SwapTheme.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxHeight: .infinity)
        .background(SwapTheme.cardBackground)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1),
            alignment: .leading
        )
    }

    private func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            content()
        }
    }
}

struct FilterOptionRow: View {
    let label: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? SwapTheme.orange : .secondary)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
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
