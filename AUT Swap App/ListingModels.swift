import SwiftUI

// MARK: - Models

enum Campus: String, CaseIterable, Identifiable, Hashable {
    case city = "City"
    case north = "North"
    case south = "South"

    var id: String { rawValue }
}

enum ListingCategory: String, CaseIterable, Identifiable, Hashable {
    case textbooks = "Textbooks"
    case furniture = "Furniture"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case graduation = "Graduation"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .textbooks: return "book.fill"
        case .furniture: return "chair.fill"
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt.fill"
        case .graduation: return "graduationcap.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum TradeType: String, CaseIterable, Identifiable, Hashable {
    case free = "Free"
    case swap = "Swap"
    case sell = "Sell"

    var id: String { rawValue }

    var filterLabel: String {
        switch self {
        case .free: return "Giveaway"
        case .swap: return "Barter"
        case .sell: return "Sale"
        }
    }

    var color: Color {
        switch self {
        case .free: return Color(red: 0.2, green: 0.65, blue: 0.35)
        case .swap: return Color(red: 0.2, green: 0.45, blue: 0.85)
        case .sell: return Color(red: 245 / 255, green: 130 / 255, blue: 32 / 255)
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case latestFirst = "Latest First"
    case priceLowHigh = "Price: Low - High"

    var id: String { rawValue }
}

enum MainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case messages = "Messages"
    case post = "Post"
    case profile = "Profile"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .post: return "plus.circle.fill"
        case .profile: return "person.fill"
        }
    }
}

struct ListingItem: Identifiable {
    let id: String
    let title: String
    let price: Double?
    let tradeType: TradeType
    let campus: Campus
    let category: ListingCategory
    let trustScore: Double?
    let isNewUser: Bool
    let imageColor: Color
    let postedAt: Date
}

// MARK: - Mock Data

enum MockData {
    static let promoBanners: [(title: String, subtitle: String)] = [
        ("Graduation Season", "Clear your dorm — list grad items today"),
        ("Free Pickup Day", "Browse free items on South campus")
    ]

    static let listings: [ListingItem] = [
        // City Campus
        ListingItem(id: "1", title: "Calculus Early Transcendentals 3rd Ed", price: 45, tradeType: .sell, campus: .city, category: .textbooks, trustScore: 4.8, isNewUser: false, imageColor: Color(red: 0.85, green: 0.9, blue: 0.95), postedAt: Date().addingTimeInterval(-1800)),
        ListingItem(id: "2", title: "MacBook Pro 13\" 2020 — Swap for iPad", price: nil, tradeType: .swap, campus: .city, category: .electronics, trustScore: nil, isNewUser: true, imageColor: Color(red: 0.75, green: 0.78, blue: 0.82), postedAt: Date().addingTimeInterval(-3600)),
        ListingItem(id: "3", title: "Monitor 27\" Dell UltraSharp", price: 180, tradeType: .sell, campus: .city, category: .electronics, trustScore: 4.7, isNewUser: false, imageColor: Color(red: 0.8, green: 0.85, blue: 0.88), postedAt: Date().addingTimeInterval(-5400)),
        ListingItem(id: "4", title: "Statistics for Business Textbook", price: 30, tradeType: .sell, campus: .city, category: .textbooks, trustScore: 4.5, isNewUser: false, imageColor: Color(red: 0.88, green: 0.92, blue: 0.9), postedAt: Date().addingTimeInterval(-7200)),
        ListingItem(id: "5", title: "Office Chair — Ergonomic", price: 55, tradeType: .sell, campus: .city, category: .furniture, trustScore: 4.6, isNewUser: false, imageColor: Color(red: 0.9, green: 0.87, blue: 0.8), postedAt: Date().addingTimeInterval(-9000)),
        ListingItem(id: "6", title: "iPad Air 4 + Apple Pencil", price: 420, tradeType: .sell, campus: .city, category: .electronics, trustScore: 4.9, isNewUser: false, imageColor: Color(red: 0.78, green: 0.82, blue: 0.88), postedAt: Date().addingTimeInterval(-10800)),
        ListingItem(id: "7", title: "Hoodie AUT Branded — L", price: 25, tradeType: .sell, campus: .city, category: .clothing, trustScore: 4.3, isNewUser: false, imageColor: Color(red: 0.82, green: 0.85, blue: 0.9), postedAt: Date().addingTimeInterval(-12600)),
        ListingItem(id: "8", title: "Marketing Notes Bundle — Free", price: nil, tradeType: .free, campus: .city, category: .textbooks, trustScore: 4.1, isNewUser: false, imageColor: Color(red: 0.86, green: 0.9, blue: 0.86), postedAt: Date().addingTimeInterval(-14400)),
        ListingItem(id: "9", title: "Bluetooth Speaker JBL", price: nil, tradeType: .swap, campus: .city, category: .electronics, trustScore: 4.4, isNewUser: false, imageColor: Color(red: 0.72, green: 0.76, blue: 0.8), postedAt: Date().addingTimeInterval(-16200)),
        ListingItem(id: "10", title: "Desk Lamp + Study Organiser", price: 15, tradeType: .sell, campus: .city, category: .other, trustScore: nil, isNewUser: true, imageColor: Color(red: 0.91, green: 0.89, blue: 0.84), postedAt: Date().addingTimeInterval(-18000)),

        // North Campus
        ListingItem(id: "11", title: "IKEA Desk + Chair Bundle", price: nil, tradeType: .free, campus: .north, category: .furniture, trustScore: 4.5, isNewUser: false, imageColor: Color(red: 0.92, green: 0.88, blue: 0.8), postedAt: Date().addingTimeInterval(-2100)),
        ListingItem(id: "12", title: "Graduation Gown + Cap", price: 20, tradeType: .sell, campus: .north, category: .graduation, trustScore: 4.2, isNewUser: false, imageColor: Color(red: 0.9, green: 0.92, blue: 0.85), postedAt: Date().addingTimeInterval(-4200)),
        ListingItem(id: "13", title: "Mini Fridge — Good Condition", price: 60, tradeType: .sell, campus: .north, category: .other, trustScore: 4.6, isNewUser: false, imageColor: Color(red: 0.9, green: 0.88, blue: 0.82), postedAt: Date().addingTimeInterval(-6300)),
        ListingItem(id: "14", title: "Accounting Principles 4th Ed", price: 38, tradeType: .sell, campus: .north, category: .textbooks, trustScore: 4.7, isNewUser: false, imageColor: Color(red: 0.84, green: 0.88, blue: 0.94), postedAt: Date().addingTimeInterval(-8400)),
        ListingItem(id: "15", title: "Single Bed Frame + Mattress", price: 80, tradeType: .sell, campus: .north, category: .furniture, trustScore: 4.0, isNewUser: false, imageColor: Color(red: 0.88, green: 0.86, blue: 0.78), postedAt: Date().addingTimeInterval(-10500)),
        ListingItem(id: "16", title: "Graphic Calculator TI-84", price: nil, tradeType: .swap, campus: .north, category: .electronics, trustScore: 4.8, isNewUser: false, imageColor: Color(red: 0.76, green: 0.8, blue: 0.84), postedAt: Date().addingTimeInterval(-12300)),
        ListingItem(id: "17", title: "Winter Coat North Face — M", price: 70, tradeType: .sell, campus: .north, category: .clothing, trustScore: 4.5, isNewUser: false, imageColor: Color(red: 0.87, green: 0.84, blue: 0.88), postedAt: Date().addingTimeInterval(-14100)),
        ListingItem(id: "18", title: "Kitchenware Set — 12 Pieces", price: nil, tradeType: .free, campus: .north, category: .other, trustScore: nil, isNewUser: true, imageColor: Color(red: 0.89, green: 0.91, blue: 0.87), postedAt: Date().addingTimeInterval(-15900)),
        ListingItem(id: "19", title: "Sofa Bed — Pick Up Only", price: 120, tradeType: .sell, campus: .north, category: .furniture, trustScore: 4.3, isNewUser: false, imageColor: Color(red: 0.93, green: 0.9, blue: 0.82), postedAt: Date().addingTimeInterval(-17700)),
        ListingItem(id: "20", title: "Graduation Stole + Sash", price: 12, tradeType: .sell, campus: .north, category: .graduation, trustScore: 4.6, isNewUser: false, imageColor: Color(red: 0.91, green: 0.88, blue: 0.9), postedAt: Date().addingTimeInterval(-19500)),

        // South Campus
        ListingItem(id: "21", title: "Winter Jacket — Size M", price: 35, tradeType: .sell, campus: .south, category: .clothing, trustScore: 4.9, isNewUser: false, imageColor: Color(red: 0.88, green: 0.85, blue: 0.9), postedAt: Date().addingTimeInterval(-2400)),
        ListingItem(id: "22", title: "Physics Lab Manual — Free", price: nil, tradeType: .free, campus: .south, category: .textbooks, trustScore: nil, isNewUser: true, imageColor: Color(red: 0.86, green: 0.9, blue: 0.86), postedAt: Date().addingTimeInterval(-4800)),
        ListingItem(id: "23", title: "Wireless Mouse + Keyboard", price: 18, tradeType: .sell, campus: .south, category: .electronics, trustScore: 4.2, isNewUser: false, imageColor: Color(red: 0.79, green: 0.83, blue: 0.87), postedAt: Date().addingTimeInterval(-6600)),
        ListingItem(id: "24", title: "Biology Campbell 12th Ed", price: 50, tradeType: .sell, campus: .south, category: .textbooks, trustScore: 4.8, isNewUser: false, imageColor: Color(red: 0.87, green: 0.91, blue: 0.88), postedAt: Date().addingTimeInterval(-8700)),
        ListingItem(id: "25", title: "Bookshelf — Wooden 5 Tier", price: 35, tradeType: .sell, campus: .south, category: .furniture, trustScore: 4.4, isNewUser: false, imageColor: Color(red: 0.9, green: 0.86, blue: 0.79), postedAt: Date().addingTimeInterval(-10200)),
        ListingItem(id: "26", title: "Nike Running Shoes — US 9", price: nil, tradeType: .swap, campus: .south, category: .clothing, trustScore: 4.6, isNewUser: false, imageColor: Color(red: 0.85, green: 0.88, blue: 0.92), postedAt: Date().addingTimeInterval(-12000)),
        ListingItem(id: "27", title: "Microwave — 20L Working", price: 40, tradeType: .sell, campus: .south, category: .other, trustScore: 4.1, isNewUser: false, imageColor: Color(red: 0.88, green: 0.9, blue: 0.85), postedAt: Date().addingTimeInterval(-13800)),
        ListingItem(id: "28", title: "Law Ethics Textbook 2024", price: 42, tradeType: .sell, campus: .south, category: .textbooks, trustScore: 4.7, isNewUser: false, imageColor: Color(red: 0.83, green: 0.87, blue: 0.93), postedAt: Date().addingTimeInterval(-15600)),
        ListingItem(id: "29", title: "Graduation Photo Frame Set", price: nil, tradeType: .free, campus: .south, category: .graduation, trustScore: 4.0, isNewUser: false, imageColor: Color(red: 0.9, green: 0.93, blue: 0.88), postedAt: Date().addingTimeInterval(-17400)),
        ListingItem(id: "30", title: "Gaming Headset — RGB", price: 28, tradeType: .sell, campus: .south, category: .electronics, trustScore: nil, isNewUser: true, imageColor: Color(red: 0.74, green: 0.77, blue: 0.85), postedAt: Date().addingTimeInterval(-19200))
    ]
}

// MARK: - Campus persistence

enum CampusStorage {
    private static let key = "aut_swap_last_campus"

    static func load() -> Campus {
        guard let raw = UserDefaults.standard.string(forKey: key),
              let campus = Campus(rawValue: raw)
        else { return .city }
        return campus
    }

    static func save(_ campus: Campus) {
        UserDefaults.standard.set(campus.rawValue, forKey: key)
    }
}

// MARK: - Filter persistence

enum FilterStorage {
    private static let categoriesKey = "aut_swap_filter_categories"
    private static let tradeTypesKey = "aut_swap_filter_trade_types"
    private static let campusesKey = "aut_swap_filter_campuses"

    static func loadCategories() -> Set<ListingCategory> {
        guard let raw = UserDefaults.standard.array(forKey: categoriesKey) as? [String] else {
            return []
        }
        return Set(raw.compactMap { ListingCategory(rawValue: $0) })
    }

    static func saveCategories(_ categories: Set<ListingCategory>) {
        let raw = categories.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: categoriesKey)
    }

    static func loadTradeTypes() -> Set<TradeType> {
        guard let raw = UserDefaults.standard.array(forKey: tradeTypesKey) as? [String] else {
            return []
        }
        return Set(raw.compactMap { TradeType(rawValue: $0) })
    }

    static func saveTradeTypes(_ types: Set<TradeType>) {
        let raw = types.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: tradeTypesKey)
    }

    static func loadCampuses() -> Set<Campus> {
        guard let raw = UserDefaults.standard.array(forKey: campusesKey) as? [String],
              !raw.isEmpty
        else {
            return [CampusStorage.load()]
        }
        let set = Set(raw.compactMap { Campus(rawValue: $0) })
        return set.isEmpty ? [CampusStorage.load()] : set
    }

    static func saveCampuses(_ campuses: Set<Campus>) {
        let raw = campuses.map { $0.rawValue }
        UserDefaults.standard.set(raw, forKey: campusesKey)
    }
}

// MARK: - Listing counts (for filter panel)

enum ListingCounts {
    static func campusCount(_ campus: Campus) -> Int {
        MockData.listings.filter { $0.campus == campus }.count
    }

    static func categoryCount(_ category: ListingCategory, campuses: Set<Campus>) -> Int {
        MockData.listings.filter { campuses.contains($0.campus) && $0.category == category }.count
    }

    static func tradeTypeCount(_ type: TradeType, campuses: Set<Campus>) -> Int {
        MockData.listings.filter { campuses.contains($0.campus) && $0.tradeType == type }.count
    }
}
