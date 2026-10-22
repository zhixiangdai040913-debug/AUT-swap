import SwiftUI

struct GiveawayBannerView: View {
    var isActive: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Giveaway Today")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    HStack(spacing: 10) {
                        Text("Free items · No strings attached")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.brandOrange)
                    }
                }
                Spacer(minLength: 8)
                illustration
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .frame(height: 86)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.bannerYellow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isActive ? AppTheme.brandOrange : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Giveaway Today. Free items, no strings attached")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private var illustration: some View {
        ZStack(alignment: .bottom) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: 0x5DAA4E))
                .rotationEffect(.degrees(-20))
                .offset(x: -14, y: -30)
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: 0xD49A5C))
                .offset(x: -14)
            Image(systemName: "lamp.desk.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(hex: 0x6E8EF5))
                .offset(x: 26, y: -2)
            Circle()
                .fill(Color(hex: 0xF5B342))
                .frame(width: 6, height: 6)
                .offset(x: -42, y: -48)
            Circle()
                .fill(Color(hex: 0xF5B342))
                .frame(width: 4, height: 4)
                .offset(x: -30, y: -56)
        }
        .frame(width: 96, height: 70)
        .accessibilityHidden(true)
    }
}
