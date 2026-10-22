import SwiftUI

struct MainTabBar: View {
    @Binding var selectedTab: MainTab
    var onPublish: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabButton(.home, title: "Home", icon: "house", selectedIcon: "house.fill")
            tabButton(.categories, title: "Categories", icon: "square.grid.2x2", selectedIcon: "square.grid.2x2.fill")
            publishButton
            tabButton(.messages, title: "Messages", icon: "envelope", selectedIcon: "envelope.fill")
            tabButton(.profile, title: "Profile", icon: "person", selectedIcon: "person.fill")
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(_ tab: MainTab, title: String, icon: String, selectedIcon: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? AppTheme.brandOrange : AppTheme.icon)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var publishButton: some View {
        Button(action: onPublish) {
            VStack(spacing: 4) {
                Circle()
                    .fill(AppTheme.brandOrange)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: AppTheme.brandOrange.opacity(0.35), radius: 6, x: 0, y: 3)
                    .padding(.top, -24)
                Text("Publish")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.icon)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Publish an item")
    }
}
