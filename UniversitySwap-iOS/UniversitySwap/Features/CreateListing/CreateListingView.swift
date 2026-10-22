import PhotosUI
import SwiftUI

struct CreateListingView: View {
    @EnvironmentObject private var listingStore: ListingStore
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CreateListingViewModel()
    @FocusState private var focusedField: Field?

    var onClose: () -> Void
    var onPosted: (Listing) -> Void

    private enum Field: Hashable {
        case title
        case price
        case lookingFor
        case description
    }

    private let horizontalPadding: CGFloat = 16
    private let photoTileSize: CGFloat = 110
    private let threeColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                sectionTitle("1. Add Photos")
                    .padding(.top, 8)
                photoRow
                    .padding(.top, 12)

                Divider()
                    .overlay(AppTheme.divider)
                    .padding(.vertical, 18)

                sectionTitle("2. Item Information")
                itemInformation
                    .padding(.top, 14)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.white)
        .safeAreaInset(edge: .bottom, spacing: 0) { nextButton }
        .navigationTitle("Post Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: close) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                .accessibilityLabel("Back")
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .onChange(of: viewModel.pickerItems) { items in
            guard !items.isEmpty else { return }
            Task { await viewModel.loadPickedPhotos() }
        }
        .confirmationDialog(
            "Discard this listing?",
            isPresented: $viewModel.isShowingDiscardDialog,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive, action: onClose)
            Button("Keep Editing", role: .cancel) {}
        }
        .alert("Post this item?", isPresented: $viewModel.isShowingConfirmation) {
            Button("Edit", role: .cancel) {}
            Button("Post", action: post)
        } message: {
            Text(viewModel.confirmationSummary)
        }
        .alert(
            "Could not post listing",
            isPresented: Binding(
                get: { viewModel.postError != nil },
                set: { if !$0 { viewModel.postError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { viewModel.postError = nil }
        } message: {
            Text(viewModel.postError ?? "")
        }
        .overlay {
            if viewModel.isPosting {
                ZStack {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(AppTheme.brandOrange)
                        Text("Uploading…")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                    )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Uploading listing")
            }
        }
        .interactiveDismissDisabled(viewModel.isPosting)
    }

    // MARK: - Photos

    private var photoRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.photos) { photo in
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: photoTileSize, height: photoTileSize)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                viewModel.removePhoto(photo)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 22, height: 22)
                                    .background(Circle().fill(Color.black.opacity(0.55)))
                            }
                            .padding(6)
                            .accessibilityLabel("Remove photo")
                        }
                }

                if viewModel.remainingPhotoSlots > 0 {
                    PhotosPicker(
                        selection: $viewModel.pickerItems,
                        maxSelectionCount: viewModel.remainingPhotoSlots,
                        matching: .images
                    ) {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Add Photo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("(up to \(CreateListingViewModel.maxPhotos))")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .frame(width: photoTileSize, height: photoTileSize)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppTheme.fieldFill)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Item information

    private var itemInformation: some View {
        VStack(alignment: .leading, spacing: 18) {
            fieldGroup("Title", isRequired: true) {
                TextField(
                    "",
                    text: $viewModel.title,
                    prompt: Text("e.g. Desk Chair").foregroundColor(AppTheme.placeholder)
                )
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit { focusedField = .description }
                .modifier(FormFieldStyle(isFocused: focusedField == .title))
            }

            fieldGroup("Category", isRequired: true) { categoryPicker }

            fieldGroup("Transaction Type", isRequired: true) { tradeTypePicker }

            if let tradeType = viewModel.tradeType {
                tradeTypeDetail(for: tradeType)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            fieldGroup("Description", isRequired: true) {
                TextField(
                    "",
                    text: $viewModel.description,
                    prompt: Text("Tell us more about your item...").foregroundColor(AppTheme.placeholder),
                    axis: .vertical
                )
                .lineLimit(4...8)
                .focused($focusedField, equals: .description)
                .modifier(FormFieldStyle(isFocused: focusedField == .description, isMultiline: true))
            }

            fieldGroup("Campus", isRequired: true) { campusPicker }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.tradeType)
    }

    private var categoryPicker: some View {
        Menu {
            Picker("Category", selection: $viewModel.category) {
                ForEach(ListingCategory.allCases) { category in
                    Label(category.rawValue, systemImage: category.iconName)
                        .tag(Optional(category))
                }
            }
        } label: {
            HStack {
                Text(viewModel.category?.rawValue ?? "Select a category")
                    .foregroundColor(viewModel.category == nil ? AppTheme.placeholder : AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.icon)
            }
            .modifier(FormFieldStyle(isFocused: false))
        }
    }

    private var tradeTypePicker: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(TradeType.allCases) { type in
                let isSelected = viewModel.tradeType == type
                Button {
                    viewModel.tradeType = type
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
                    .background(Capsule().fill(isSelected ? type.badgeColor : type.lightBackground))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func tradeTypeDetail(for type: TradeType) -> some View {
        switch type {
        case .giveaway:
            fieldGroup("Price", isRequired: false) {
                HStack(spacing: 10) {
                    Text("FREE")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.giveawayGreen)
                    Text("This item will be listed as a giveaway")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                    Spacer()
                    Image(systemName: TradeType.giveaway.iconName)
                        .foregroundColor(AppTheme.giveawayGreen)
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TradeType.giveaway.lightBackground)
                )
            }
        case .swap:
            fieldGroup("What are you looking for?", isRequired: true) {
                TextField(
                    "",
                    text: $viewModel.lookingFor,
                    prompt: Text("e.g. Calculator, textbook, desk lamp").foregroundColor(AppTheme.placeholder)
                )
                .focused($focusedField, equals: .lookingFor)
                .modifier(FormFieldStyle(isFocused: focusedField == .lookingFor))
            }
        case .sell:
            fieldGroup("Price", isRequired: true) {
                HStack(spacing: 6) {
                    Text("$")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    TextField(
                        "",
                        text: $viewModel.priceText,
                        prompt: Text("0").foregroundColor(AppTheme.placeholder)
                    )
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    Text("NZD")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .modifier(FormFieldStyle(isFocused: focusedField == .price))
            }
        }
    }

    private var campusPicker: some View {
        LazyVGrid(columns: threeColumns, spacing: 12) {
            ForEach(Campus.allCases) { campus in
                let isSelected = viewModel.campus == campus
                Button {
                    viewModel.campus = campus
                } label: {
                    Text(campus.rawValue)
                        .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .white : AppTheme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Capsule().fill(isSelected ? AppTheme.brandOrange : AppTheme.fieldFill))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }

    private var nextButton: some View {
        Button {
            focusedField = nil
            viewModel.isShowingConfirmation = true
        } label: {
            Text("Next")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule().fill(AppTheme.brandOrange.opacity(viewModel.canSubmit ? 1 : 0.45))
                )
        }
        .disabled(!viewModel.canSubmit)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Color.white)
    }

    // MARK: - Building blocks

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(AppTheme.textPrimary)
    }

    private func fieldGroup<Content: View>(
        _ label: String,
        isRequired: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            (Text(label).foregroundColor(AppTheme.textSecondary)
                + Text(isRequired ? " *" : "").foregroundColor(AppTheme.requiredRed))
                .font(.system(size: 14, weight: .semibold))
            content()
        }
    }

    // MARK: - Actions

    private func close() {
        if viewModel.hasChanges {
            viewModel.isShowingDiscardDialog = true
        } else {
            onClose()
        }
    }

    private func post() {
        guard appState.isAuthenticated else {
            viewModel.postError = AuthServiceError.notAuthenticated.localizedDescription
            return
        }
        Task {
            guard let listing = await viewModel.publish(seller: appState.currentSeller) else { return }
            listingStore.add(listing)
            onPosted(listing)
        }
    }
}

private struct FormFieldStyle: ViewModifier {
    var isFocused: Bool
    var isMultiline = false

    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, isMultiline ? 14 : 0)
            .frame(minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused ? AppTheme.brandOrange.opacity(0.6) : AppTheme.border, lineWidth: 1)
            )
    }
}

struct CreateListingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateListingView(onClose: {}, onPosted: { _ in })
        }
        .environmentObject(ListingStore())
        .environmentObject(AppState())
    }
}
