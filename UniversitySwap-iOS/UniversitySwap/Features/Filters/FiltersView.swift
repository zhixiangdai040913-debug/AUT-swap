import SwiftUI

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FiltersViewModel
    private let onApply: (ListingFilters) -> Void

    private let threeColumns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    init(filters: ListingFilters, onApply: @escaping (ListingFilters) -> Void) {
        _viewModel = StateObject(wrappedValue: FiltersViewModel(filters: filters))
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    section("Campus") { campusOptions }
                    sectionDivider
                    section("Categories") { categoryGrid }
                    sectionDivider
                    section("Transaction Type") { tradeTypeOptions }
                    sectionDivider
                    section("Sort By") { sortOptions }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .safeAreaInset(edge: .bottom, spacing: 0) { applyButton }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    // MARK: - Sections

    private var campusOptions: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(Campus.allCases) { campus in
                pillButton(
                    title: campus.rawValue,
                    isSelected: viewModel.filters.campus == campus
                ) {
                    viewModel.filters.campus = campus
                }
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(ListingCategory.allCases) { category in
                let isSelected = viewModel.filters.categories.contains(category)
                Button {
                    viewModel.toggleCategory(category)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(category.tint)
                            .frame(height: 26)
                        Text(category.rawValue)
                            .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 84)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(category.background.opacity(0.75))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? category.tint : Color.clear, lineWidth: 1.5)
                    )
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(category.tint)
                                .padding(6)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var tradeTypeOptions: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(TradeType.allCases) { type in
                let isSelected = viewModel.filters.tradeTypes.contains(type)
                Button {
                    viewModel.toggleTradeType(type)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: type.iconName)
                            .font(.system(size: 13, weight: .semibold))
                        Text(type.filterTitle)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(isSelected ? .white : type.badgeColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        Capsule().fill(isSelected ? type.badgeColor : type.lightBackground)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var sortOptions: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(ListingSort.allCases) { sort in
                pillButton(
                    title: sort.title,
                    trailingIcon: sort == .price ? "arrow.up" : nil,
                    isSelected: viewModel.filters.sort == sort
                ) {
                    viewModel.filters.sort = sort
                }
            }
        }
    }

    private var applyButton: some View {
        Button {
            onApply(viewModel.filters)
            dismiss()
        } label: {
            Text("Apply")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(AppTheme.brandOrange))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
    }

    // MARK: - Building blocks

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            content()
        }
        .padding(.vertical, 16)
    }

    private var sectionDivider: some View {
        Divider().overlay(AppTheme.divider)
    }

    private func pillButton(
        title: String,
        trailingIcon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Text(title)
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
            .foregroundColor(isSelected ? .white : AppTheme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                Capsule().fill(isSelected ? AppTheme.brandOrange : AppTheme.fieldFill)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView(filters: ListingFilters()) { _ in }
    }
}
