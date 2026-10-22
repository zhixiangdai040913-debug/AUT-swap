import SwiftUI

extension ListingCategory {
    var iconName: String {
        switch self {
        case .textbooks: return "book.fill"
        case .furniture: return "chair.lounge.fill"
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt.fill"
        case .graduation: return "graduationcap.fill"
        case .other: return "ellipsis"
        }
    }

    var tint: Color {
        switch self {
        case .textbooks: return Color(hex: 0x3B82F6)
        case .furniture: return Color(hex: 0xF97316)
        case .electronics: return Color(hex: 0x7C5CFA)
        case .clothing: return Color(hex: 0xEF4444)
        case .graduation: return Color(hex: 0x16A34A)
        case .other: return Color(hex: 0x8A93A3)
        }
    }

    var background: Color {
        switch self {
        case .textbooks: return Color(hex: 0xE8F0FE)
        case .furniture: return Color(hex: 0xFFF1E6)
        case .electronics: return Color(hex: 0xEFEBFF)
        case .clothing: return Color(hex: 0xFDECEC)
        case .graduation: return Color(hex: 0xE6F6EC)
        case .other: return Color(hex: 0xF1F3F6)
        }
    }
}

extension TradeType {
    var badgeColor: Color {
        switch self {
        case .giveaway: return AppTheme.giveawayGreen
        case .swap, .sell: return AppTheme.brandOrange
        }
    }

    var lightBackground: Color {
        switch self {
        case .giveaway: return Color(hex: 0xE7F6EA)
        case .swap, .sell: return Color(hex: 0xFFF1E6)
        }
    }

    var iconName: String {
        switch self {
        case .giveaway: return "gift"
        case .swap, .sell: return "tag"
        }
    }
}
