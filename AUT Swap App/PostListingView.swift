import SwiftUI

struct PostListingView: View {
    @ObservedObject var listingStore: ListingStore
    let sellerName: String
    let sellerEmail: String
    var onPublished: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var priceText = ""
    @State private var selectedCategory: ListingCategory = .textbooks
    @State private var selectedCampus: Campus = CampusStorage.load()
    @State private var selectedTradeType: TradeType = .sell
    @State private var photoURLs: [URL] = []
    @State private var showSuccess = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Post a Listing")
                    .font(.title2)
                    .fontWeight(.bold)

                formSection("Title") {
                    TextField("e.g. Calculus Textbook 3rd Ed", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                formSection("Description") {
                    TextField("Describe condition, pickup location, etc.", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                formSection("Transaction Type") {
                    Picker("Type", selection: $selectedTradeType) {
                        ForEach(TradeType.allCases) { type in
                            Text(type.filterLabel).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if selectedTradeType == .sell {
                    formSection("Price (NZD)") {
                        TextField("e.g. 45", text: $priceText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }

                formSection("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ListingCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .labelsHidden()
                }

                formSection("Campus") {
                    Picker("Campus", selection: $selectedCampus) {
                        ForEach(Campus.allCases) { campus in
                            Text(campus.rawValue).tag(campus)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                ListingPhotoPicker(selectedURLs: $photoURLs, maxCount: 6)

                Button(action: publishListing) {
                    Text("Publish Listing")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(canPublish ? SwapTheme.orange : Color.gray)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canPublish)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Listing Published"),
                message: Text("Your item is now live on AUT Swap."),
                dismissButton: .default(Text("OK"), action: onPublished)
            )
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !description.trimmingCharacters(in: .whitespaces).isEmpty
            && (selectedTradeType != .sell || Double(priceText) != nil)
    }

    private func publishListing() {
        let price: Double? = selectedTradeType == .sell ? Double(priceText) : nil
        listingStore.addListing(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            price: price,
            tradeType: selectedTradeType,
            campus: selectedCampus,
            category: selectedCategory,
            sellerName: sellerName,
            sellerEmail: sellerEmail,
            photoURLs: photoURLs
        )
        title = ""
        description = ""
        priceText = ""
        photoURLs = []
        showSuccess = true
    }
}
