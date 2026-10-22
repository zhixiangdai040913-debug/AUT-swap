import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var listingStore: ListingStore
    @EnvironmentObject private var favoritesStore: FavoritesStore
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingLogOutConfirmation = false

    var onOpenMessages: () -> Void = {}

    private let horizontalPadding: CGFloat = 18
    private let trustCardFill = Color(hex: 0xFFF3E8)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                header
                    .padding(.top, 6)
                profileSummary
                    .padding(.top, 18)
                trustCard
                    .padding(.top, 22)
                menu
                    .padding(.top, 18)
                logOutButton
                    .padding(.top, 24)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 28)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .settings:
                SettingsView()
            case .favorites:
                FavoritesView()
            case .myListings:
                MyListingsView()
            case .myTransactions:
                PlaceholderContent(
                    title: route.title,
                    systemImage: route.iconName,
                    message: "Transactions are not part of this demo. Browse, favorite, publish, and message instead."
                )
                .navigationTitle(route.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarRole(.editor)
            }
        }
        .confirmationDialog(
            "Log out of University Swap?",
            isPresented: $isShowingLogOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                appState.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Image("AUTLogo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 40, height: 40)
                .accessibilityLabel("AUT")

            HStack {
                Spacer()
                NavigationLink(value: ProfileRoute.settings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("Settings")
            }
        }
        .frame(height: 44)
    }

    // MARK: - Summary

    private var profileSummary: some View {
        HStack(spacing: 18) {
            avatar

            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.displayName(for: appState.currentEmail))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .textSelection(.enabled)

                if let badgeTitle = viewModel.badgeTitle(for: appState.accountType) {
                    verifiedBadge(title: badgeTitle)
                }

                Text(viewModel.levelText)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
            }
            Spacer(minLength: 0)
        }
    }

    private var avatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [AppTheme.brandOrange.opacity(0.18), AppTheme.brandOrange.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 88, height: 88)
            .overlay(
                Text(viewModel.initials(for: appState.currentEmail))
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(AppTheme.brandOrange)
            )
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            .overlay(alignment: .bottomTrailing) {
                if viewModel.badgeTitle(for: appState.accountType) != nil {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.verifiedBlue)
                        .background(Circle().fill(Color.white).padding(1))
                        .offset(x: -2, y: -2)
                }
            }
            .accessibilityHidden(true)
    }

    private func verifiedBadge(title: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
            Text(title)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(AppTheme.verifiedBlue)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppTheme.verifiedBlue.opacity(0.1)))
        .accessibilityLabel("Verified \(title)")
    }

    // MARK: - Trust card

    private var trustCard: some View {
        NavigationLink(value: AppRoute.trustworthiness(userId: viewModel.userId)) {
            HStack(spacing: 14) {
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.starYellow)

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.ratingText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Trustworthiness Score")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(viewModel.reviewsText)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.brandOrange)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(trustCardFill)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows trustworthiness score and reviews")
    }

    // MARK: - Menu

    private var menu: some View {
        VStack(spacing: 0) {
            Group {
                NavigationLink(value: ProfileRoute.myListings) {
                    menuRow(
                        icon: "square.grid.2x2",
                        title: "My Listings",
                        count: viewModel.listingCount(
                            in: listingStore.listings,
                            userId: appState.currentUserId ?? appState.currentSeller.id
                        )
                    )
                }
                menuDivider
                NavigationLink(value: ProfileRoute.favorites) {
                    menuRow(
                        icon: "heart",
                        title: "Favorites",
                        count: favoritesStore.favoriteIDs.count
                    )
                }
                menuDivider
                NavigationLink(value: ProfileRoute.myTransactions) {
                    menuRow(
                        icon: "arrow.left.arrow.right.circle",
                        title: "My Transactions",
                        count: viewModel.transactionCount
                    )
                }
                menuDivider
                NavigationLink(value: AppRoute.trustworthiness(userId: viewModel.userId)) {
                    menuRow(icon: "star.bubble", title: "My Reviews", count: viewModel.user.reviewCount)
                }
            }
            Group {
                menuDivider
                NavigationLink(value: ProfileRoute.settings) {
                    menuRow(icon: "gearshape", title: "Settings")
                }
                menuDivider
                Button {
                    onOpenMessages()
                } label: {
                    menuRow(icon: "bubble.left", title: "Messages")
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func menuRow(icon: String, title: String, count: Int? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 26)
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textPrimary)
            Spacer(minLength: 0)
            if let count {
                Text("\(count)")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.icon)
        }
        .frame(height: 54)
        .contentShape(Rectangle())
    }

    private var menuDivider: some View {
        Rectangle()
            .fill(AppTheme.divider)
            .frame(height: 1)
            .padding(.leading, 40)
    }

    private var logOutButton: some View {
        Button {
            isShowingLogOutConfirmation = true
        } label: {
            Text("Log Out")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.requiredRed)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.requiredRed.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .withAppRoutes()
        }
        .environmentObject(AppState())
        .environmentObject(ListingStore())
        .environmentObject(FavoritesStore())
        .environmentObject(ChatStore())
    }
}
