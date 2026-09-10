import SwiftUI

struct ProfileView: View {
    let userEmail: String
    @ObservedObject var listingStore: ListingStore
    @ObservedObject var cart: CartStore
    @ObservedObject var messageStore: MessageStore
    var onLogout: () -> Void
    var onBrowse: () -> Void
    var onPost: () -> Void
    var onOpenMessages: () -> Void
    var onSelectListing: (ListingItem) -> Void

    @State private var preferredCampus: Campus = CampusStorage.load()
    @State private var displayNameText = ""
    @State private var showLogoutConfirm = false

    private var myListings: [ListingItem] {
        listingStore.listingsBySeller(userEmail)
    }

    private var displayName: String {
        let trimmed = displayNameText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return Self.nameFromEmail(userEmail)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                statsRow
                campusCard
                myListingsSection
                accountActions
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SwapTheme.background)
        .onAppear {
            if displayNameText.isEmpty {
                displayNameText = ProfileStorage.loadDisplayName(for: userEmail)
                    ?? Self.nameFromEmail(userEmail)
            }
        }
        .alert(isPresented: $showLogoutConfirm) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you want to log out of AUT Swap?"),
                primaryButton: .destructive(Text("Log Out"), action: onLogout),
                secondaryButton: .cancel()
            )
        }
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(SwapTheme.orangeLight)
                .frame(width: 72, height: 72)
                .overlay(
                    Text(String(displayName.prefix(1)).uppercased())
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(SwapTheme.orange)
                )

            VStack(alignment: .leading, spacing: 6) {
                TextField("Display name", text: $displayNameText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title3)
                    .fontWeight(.bold)
                    .onChange(of: displayNameText) { value in
                        ProfileStorage.saveDisplayName(value, for: userEmail)
                    }
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("AUT student / staff account")
                    .font(.caption)
                    .foregroundColor(SwapTheme.orange)
            }
            Spacer()
        }
        .padding(20)
        .background(SwapTheme.cardBackground)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            ProfileStatCard(title: "My Listings", value: "\(myListings.count)", icon: "tag.fill") {
                // scroll focus is local; no-op
            }
            ProfileStatCard(title: "Cart", value: "\(cart.count)", icon: "cart.fill", action: onBrowse)
            ProfileStatCard(title: "Unread", value: "\(messageStore.unreadTotal)", icon: "bubble.left.fill", action: onOpenMessages)
        }
    }

    private var campusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferred Campus")
                .font(.headline)
            Text("Used for sorting and default filters on Home.")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 10) {
                ForEach(Campus.allCases) { campus in
                    Button(action: {
                        preferredCampus = campus
                        CampusStorage.save(campus)
                    }) {
                        Text(campus.rawValue)
                            .font(.system(size: 14, weight: preferredCampus == campus ? .semibold : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(preferredCampus == campus ? SwapTheme.orange : Color(white: 0.94))
                            .foregroundColor(preferredCampus == campus ? .white : .primary)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(SwapTheme.cardBackground)
        .cornerRadius(14)
    }

    private var myListingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Listings")
                    .font(.headline)
                Spacer()
                Button(action: onPost) {
                    Label("Post New", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(SwapTheme.orange)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if myListings.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("You haven't posted anything yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button(action: onPost) {
                        Text("Create your first listing")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .background(SwapTheme.orange)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else {
                ForEach(myListings) { item in
                    ProfileListingRow(
                        item: item,
                        onTap: { onSelectListing(item) },
                        onDelete: { listingStore.removeListing(id: item.id) }
                    )
                }
            }
        }
        .padding(16)
        .background(SwapTheme.cardBackground)
        .cornerRadius(14)
    }

    private var accountActions: some View {
        VStack(spacing: 10) {
            Button(action: onOpenMessages) {
                settingsRow(icon: "bubble.left.and.bubble.right.fill", title: "Messages", detail: messageStore.unreadTotal > 0 ? "\(messageStore.unreadTotal) unread" : nil)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onBrowse) {
                settingsRow(icon: "house.fill", title: "Browse Home", detail: nil)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { showLogoutConfirm = true }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(SwapTheme.priceRed)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
        .padding(16)
        .background(SwapTheme.cardBackground)
        .cornerRadius(14)
    }

    private func settingsRow(icon: String, title: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(SwapTheme.orange)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if let detail = detail {
                Text(detail)
                    .font(.caption)
                    .foregroundColor(SwapTheme.orange)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }

    static func nameFromEmail(_ email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? "AUT User"
        return local.replacingOccurrences(of: ".", with: " ").capitalized
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(SwapTheme.orange)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(SwapTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileListingRow: View {
    let item: ListingItem
    var onTap: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ListingThumbnailView(item: item, cornerRadius: 8)
                        .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        HStack(spacing: 8) {
                            if let price = item.price {
                                Text("$\(Int(price))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(SwapTheme.priceRed)
                            } else {
                                Text(item.tradeType.filterLabel)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(item.tradeType.color)
                            }
                            CampusBadge(campus: item.campus)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(10)
        .background(Color(white: 0.97))
        .cornerRadius(10)
    }
}

enum ProfileStorage {
    private static func key(for email: String) -> String {
        "aut_swap_display_name_\(email.lowercased())"
    }

    static func loadDisplayName(for email: String) -> String? {
        UserDefaults.standard.string(forKey: key(for: email))
    }

    static func saveDisplayName(_ name: String, for email: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: key(for: email))
    }
}
