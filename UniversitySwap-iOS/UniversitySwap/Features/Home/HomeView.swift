import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var listingStore: ListingStore
    @StateObject private var viewModel = HomeViewModel()
    @FocusState private var isSearchFocused: Bool

    private let horizontalPadding: CGFloat = 16
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 6)
                searchBar
                    .padding(.top, 14)
                campusChips
                    .padding(.top, 14)
                GiveawayBannerView(isActive: viewModel.isGiveawayOnly) {
                    viewModel.toggleGiveawayOnly()
                }
                .padding(.top, 16)
                categoryRow
                    .padding(.top, 16)
                sortTabs
                    .padding(.top, 18)
                listingGrid
                    .padding(.top, 14)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isSearchFocused = false
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.brandOrange)
            }
        }
        .sheet(isPresented: $viewModel.isShowingFilters) {
            FiltersView(filters: viewModel.filters) { newFilters in
                viewModel.applyFilters(newFilters)
            }
        }
        .task {
            await listingStore.loadListings()
        }
        .refreshable {
            await listingStore.loadListings(force: true)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image("AUTLogo")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .accessibilityLabel("AUT")
                Text("University Swap")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer(minLength: 0)
            }
            if AppConfig.useSampleData {
                Text("Demo mode — sample listings (local, not Firebase)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .accessibilityLabel("Demo mode using sample listings")
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.icon)
            TextField(
                "",
                text: $viewModel.searchText,
                prompt: Text("Search for items, categories...").foregroundColor(AppTheme.placeholder)
            )
            .font(.system(size: 14))
            .foregroundColor(AppTheme.textPrimary)
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($isSearchFocused)
            .onSubmit { isSearchFocused = false }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.placeholder)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }

            Button {
                isSearchFocused = false
                viewModel.isShowingFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.icon)
            }
            .accessibilityLabel("Filters")
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.fieldFill)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchFocused = true
        }
    }

    private var campusChips: some View {
        HStack(spacing: 10) {
            ForEach(Campus.allCases) { campus in
                let isSelected = viewModel.filters.campus == campus
                Button {
                    viewModel.filters.campus = campus
                } label: {
                    HStack(spacing: 5) {
                        if isSelected {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(campus.rawValue)
                            .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    }
                    .foregroundColor(isSelected ? .white : AppTheme.textTertiary)
                    .padding(.horizontal, 18)
                    .frame(height: 32)
                    .background(
                        Capsule().fill(isSelected ? AppTheme.brandOrange : AppTheme.fieldFill)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer()
        }
    }

    // MARK: - Categories & sort

    private var categoryRow: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(ListingCategory.allCases) { category in
                let isSelected = viewModel.isCategorySelected(category)
                Button {
                    viewModel.toggleCategory(category)
                } label: {
                    VStack(spacing: 7) {
                        Circle()
                            .fill(category.background)
                            .frame(width: 46, height: 46)
                            .overlay(
                                Image(systemName: category.iconName)
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundColor(category.tint)
                            )
                            .overlay(
                                Circle().stroke(isSelected ? category.tint : Color.clear, lineWidth: 1.5)
                            )
                        Text(category.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var sortTabs: some View {
        HStack(spacing: 30) {
            ForEach(ListingSort.allCases) { sort in
                let isSelected = viewModel.filters.sort == sort
                Button {
                    viewModel.filters.sort = sort
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 2) {
                            Text(sort.title)
                            if sort == .price {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? AppTheme.brandOrange : AppTheme.textTertiary)

                        Capsule()
                            .fill(isSelected ? AppTheme.brandOrange : Color.clear)
                            .frame(height: 2.5)
                    }
                    .fixedSize()
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
            Spacer()
        }
    }

    // MARK: - Grid

    @ViewBuilder
    private var listingGrid: some View {
        if listingStore.isLoading && listingStore.listings.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(AppTheme.brandOrange)
                Text("Loading listings…")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
        } else if let loadError = listingStore.loadError, listingStore.listings.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 34))
                    .foregroundColor(AppTheme.icon)
                Text("Couldn’t load listings")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(loadError)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                Button("Try Again") {
                    Task { await listingStore.loadListings(force: true) }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.brandOrange)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            let listings = viewModel.visibleListings(from: listingStore.listings)
            if listings.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 34))
                        .foregroundColor(AppTheme.icon)
                    Text("No items found")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Be the first to publish, or try another filter.")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(listings) { listing in
                        NavigationLink(value: AppRoute.listingDetail(listingId: listing.id)) {
                            ListingCard(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
        .environmentObject(ChatStore())
    }
}
