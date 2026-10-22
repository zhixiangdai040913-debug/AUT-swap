import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var listingStore: ListingStore

    private let horizontalPadding: CGFloat = 16
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    /// Marketplace categories shown on this screen (matches Phase 1 brief).
    private let marketplaceCategories: [ListingCategory] = [
        .textbooks, .furniture, .electronics, .clothing, .other
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Categories")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 6)

                Text("Browse campus listings by type.")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.top, 6)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(marketplaceCategories) { category in
                        NavigationLink(value: CategoryRoute.listings(category)) {
                            categoryTile(category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 18)

                NavigationLink(value: CategoryRoute.listings(.graduation)) {
                    graduationRow
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 28)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await listingStore.loadListings()
        }
        .navigationDestination(for: CategoryRoute.self) { route in
            switch route {
            case .listings(let category):
                CategoryListingsView(category: category)
            }
        }
    }

    private func categoryTile(_ category: ListingCategory) -> some View {
        VStack(spacing: 12) {
            Circle()
                .fill(category.background)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: category.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(category.tint)
                )
            Text(category.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var graduationRow: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(ListingCategory.graduation.background)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: ListingCategory.graduation.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(ListingCategory.graduation.tint)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text("Graduation")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Gowns, caps, stoles and more")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.icon)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.fieldFill)
        )
    }
}

enum CategoryRoute: Hashable {
    case listings(ListingCategory)
}

struct CategoryListingsView: View {
    @EnvironmentObject private var listingStore: ListingStore
    let category: ListingCategory

    private let columns = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    private var listings: [Listing] {
        listingStore.listings.filter { $0.category == category }
    }

    var body: some View {
        Group {
            if listings.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: category.iconName)
                        .font(.system(size: 34))
                        .foregroundColor(AppTheme.icon)
                    Text("No \(category.rawValue.lowercased()) yet")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Published listings in this category will show up here.")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(listings) { listing in
                            NavigationLink(value: AppRoute.listingDetail(listingId: listing.id)) {
                                ListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.white)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoriesView()
                .withAppRoutes()
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
    }
}
