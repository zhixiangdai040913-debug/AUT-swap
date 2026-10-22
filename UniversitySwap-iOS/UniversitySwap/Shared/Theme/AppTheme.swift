import SwiftUI

enum AppTheme {
    static let brandOrange = Color(hex: 0xFF7A1C)
    static let textPrimary = Color(hex: 0x1D2740)
    static let textSecondary = Color(hex: 0x4A5468)
    static let textTertiary = Color(hex: 0x7C8597)
    static let placeholder = Color(hex: 0x9AA1AE)
    static let icon = Color(hex: 0x8A93A3)
    static let border = Color(hex: 0xE2E5EB)
    static let divider = Color(hex: 0xEEF0F3)
    static let fieldFill = Color(hex: 0xF3F5F8)
    static let giveawayGreen = Color(hex: 0x3DBE5C)
    static let bannerYellow = Color(hex: 0xFCF0C8)
    static let verifiedBlue = Color(hex: 0x4F6FD8)
    static let starYellow = Color(hex: 0xF5A623)
    static let requiredRed = Color(hex: 0xF04438)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
