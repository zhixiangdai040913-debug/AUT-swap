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

// MARK: - Feed & sort

enum HomeFeedTab: Hashable, Identifiable {
    case recommended
    case category(ListingCategory)

    var id: String {
        switch self {
        case .recommended: return "recommended"
        case .category(let c): return c.rawValue
        }
    }

    var title: String {
        switch self {
        case .recommended: return "Recommended"
        case .category(let c): return c.rawValue
        }
    }

    static var allTabs: [HomeFeedTab] {
        [.recommended] + ListingCategory.allCases.map { .category($0) }
    }
}

enum CategorySortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case campus = "Campus"

    var id: String { rawValue }
}

enum MainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case cart = "Cart"
    case messages = "Messages"
    case post = "Post"
    case profile = "Profile"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .cart: return "cart.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .post: return "plus.circle.fill"
        case .profile: return "person.fill"
        }
    }
}

struct ListingItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Double?
    let tradeType: TradeType
    let campus: Campus
    let category: ListingCategory
    let trustScore: Double?
    let isNewUser: Bool
    let imageColor: Color
    let imageSymbol: String
    let imageNames: [String]
    let postedAt: Date
    let sellerName: String
    let sellerEmail: String
    let sellerListingCount: Int
}

// MARK: - Mock Data

enum MockData {
    static let listings: [ListingItem] = [
        listing("1", "Calculus Early Transcendentals 3rd Ed", "Clean copy with minimal highlighting. Pick up at City campus library.", 45, .sell, .city, .textbooks, 4.8, false, "book.closed.fill", -1800),
        listing("2", "MacBook Pro 13\" 2020 — Swap for iPad", "Works perfectly. Looking to swap for iPad Air or similar.", nil, .swap, .city, .electronics, nil, true, "laptopcomputer", -3600),
        listing("3", "Monitor 27\" Dell UltraSharp", "1080p monitor, includes HDMI cable. Great for study setup.", 180, .sell, .city, .electronics, 4.7, false, "display", -5400),
        listing("4", "Statistics for Business Textbook", "Required for STATS101. No missing pages.", 30, .sell, .city, .textbooks, 4.5, false, "book.closed.fill", -7200),
        listing("5", "Office Chair — Ergonomic", "Adjustable height, good lumbar support.", 55, .sell, .city, .furniture, 4.6, false, "chair.fill", -9000),
        listing("6", "iPad Air 4 + Apple Pencil", "64GB, battery health 92%. Comes with case.", 420, .sell, .city, .electronics, 4.9, false, "laptopcomputer", -10800),
        listing("7", "Hoodie AUT Branded — L", "Official AUT hoodie, worn twice.", 25, .sell, .city, .clothing, 4.3, false, "tshirt.fill", -12600),
        listing("8", "Marketing Notes Bundle — Free", "Full semester notes PDF + printed summaries. Free to good home.", nil, .free, .city, .textbooks, 4.1, false, "doc.text.fill", -14400),
        listing("9", "Bluetooth Speaker JBL", "Portable speaker, swap for study desk lamp or headphones.", nil, .swap, .city, .electronics, 4.4, false, "hifispeaker.fill", -16200),
        listing("10", "Desk Lamp + Study Organiser", "LED lamp with USB port and pen holder tray.", 15, .sell, .city, .other, nil, true, "lightbulb.fill", -18000),
        listing("11", "IKEA Desk + Chair Bundle", "Moving out sale — must pick up from North campus dorm.", nil, .free, .north, .furniture, 4.5, false, "chair.fill", -2100),
        listing("12", "Graduation Gown + Cap", "Size M, dry cleaned after last ceremony.", 20, .sell, .north, .graduation, 4.2, false, "graduationcap.fill", -4200),
        listing("13", "Mini Fridge — Good Condition", "Compact fridge, perfect for dorm room.", 60, .sell, .north, .other, 4.6, false, "refrigerator.fill", -6300),
        listing("14", "Accounting Principles 4th Ed", "Latest edition, includes online access code (unused).", 38, .sell, .north, .textbooks, 4.7, false, "books.vertical.fill", -8400),
        listing("15", "Single Bed Frame + Mattress", "Pick up only. Disassembled for easy transport.", 80, .sell, .north, .furniture, 4.0, false, "bed.double.fill", -10500),
        listing("16", "Graphic Calculator TI-84", "Fully working. Swap for textbook or backpack.", nil, .swap, .north, .electronics, 4.8, false, "plus.forwardslash.minus", -12300),
        listing("17", "Winter Coat North Face — M", "Waterproof, great for Auckland winter.", 70, .sell, .north, .clothing, 4.5, false, "cloud.snow.fill", -14100),
        listing("18", "Kitchenware Set — 12 Pieces", "Pots, pans, utensils — free for new flatmate.", nil, .free, .north, .other, nil, true, "fork.knife", -15900),
        listing("19", "Sofa Bed — Pick Up Only", "Comfortable sofa bed, minor wear on armrest.", 120, .sell, .north, .furniture, 4.3, false, "sofa.fill", -17700),
        listing("20", "Graduation Stole + Sash", "Faculty colours included.", 12, .sell, .north, .graduation, 4.6, false, "medal.fill", -19500),
        listing("21", "Winter Jacket — Size M", "Lightweight puffer jacket, navy blue.", 35, .sell, .south, .clothing, 4.9, false, "cloud.snow.fill", -2400),
        listing("22", "Physics Lab Manual — Free", "All experiments completed, answers included.", nil, .free, .south, .textbooks, nil, true, "atom", -4800),
        listing("23", "Wireless Mouse + Keyboard", "Logitech combo, barely used.", 18, .sell, .south, .electronics, 4.2, false, "keyboard.fill", -6600),
        listing("24", "Biology Campbell 12th Ed", "Heavy textbook — meet at South campus café.", 50, .sell, .south, .textbooks, 4.8, false, "leaf.fill", -8700),
        listing("25", "Bookshelf — Wooden 5 Tier", "Sturdy bookshelf, fits dorm room corner.", 35, .sell, .south, .furniture, 4.4, false, "books.vertical.fill", -10200),
        listing("26", "Nike Running Shoes — US 9", "Swap for gym bag or water bottle bundle.", nil, .swap, .south, .clothing, 4.6, false, "figure.walk", -12000),
        listing("27", "Microwave — 20L Working", "Perfect for quick meals between classes.", 40, .sell, .south, .other, 4.1, false, "flame.fill", -13800),
        listing("28", "Law Ethics Textbook 2024", "Current edition for LAW501.", 42, .sell, .south, .textbooks, 4.7, false, "building.columns.fill", -15600),
        listing("29", "Graduation Photo Frame Set", "Set of 3 frames — free giveaway.", nil, .free, .south, .graduation, 4.0, false, "photo.fill", -17400),
        listing("30", "Gaming Headset — RGB", "USB headset with mic, great for online classes.", 28, .sell, .south, .electronics, nil, true, "headphones", -19200)
    ]

    private static let sellerNames = ["Alex Chen", "Sam Taylor", "Jordan Lee", "Casey Wong", "Riley Ng", "Morgan Park"]

    static func listing(
        _ id: String,
        _ title: String,
        _ description: String,
        _ price: Double?,
        _ tradeType: TradeType,
        _ campus: Campus,
        _ category: ListingCategory,
        _ trustScore: Double?,
        _ isNewUser: Bool,
        _ imageSymbol: String,
        _ secondsAgo: TimeInterval
    ) -> ListingItem {
        let colors: [Color] = [
            Color(red: 0.85, green: 0.9, blue: 0.95),
            Color(red: 0.75, green: 0.78, blue: 0.82),
            Color(red: 0.9, green: 0.87, blue: 0.8),
            Color(red: 0.86, green: 0.9, blue: 0.86),
            Color(red: 0.88, green: 0.85, blue: 0.9)
        ]
        let idx = abs(id.hashValue)
        let seller = sellerNames[idx % sellerNames.count]
        let num = Int(id) ?? 1
        return ListingItem(
            id: id,
            title: title,
            description: description,
            price: price,
            tradeType: tradeType,
            campus: campus,
            category: category,
            trustScore: trustScore,
            isNewUser: isNewUser,
            imageColor: colors[idx % colors.count],
            imageSymbol: imageSymbol,
            imageNames: ["listing_\(String(format: "%02d", num)).jpg"],
            postedAt: Date().addingTimeInterval(secondsAgo),
            sellerName: seller,
            sellerEmail: "\(seller.lowercased().replacingOccurrences(of: " ", with: "."))@autuni.ac.nz",
            sellerListingCount: 2 + (idx % 8)
        )
    }
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
        UserDefaults.standard.set(categories.map { $0.rawValue }, forKey: categoriesKey)
    }

    static func loadTradeTypes() -> Set<TradeType> {
        guard let raw = UserDefaults.standard.array(forKey: tradeTypesKey) as? [String] else {
            return []
        }
        return Set(raw.compactMap { TradeType(rawValue: $0) })
    }

    static func saveTradeTypes(_ types: Set<TradeType>) {
        UserDefaults.standard.set(types.map { $0.rawValue }, forKey: tradeTypesKey)
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
        UserDefaults.standard.set(campuses.map { $0.rawValue }, forKey: campusesKey)
    }
}

// MARK: - Listing counts (for filter panel)

enum ListingCounts {
    static func campusCount(_ campus: Campus, in listings: [ListingItem]) -> Int {
        listings.filter { $0.campus == campus }.count
    }

    static func categoryCount(_ category: ListingCategory, campuses: Set<Campus>, in listings: [ListingItem]) -> Int {
        listings.filter { campuses.contains($0.campus) && $0.category == category }.count
    }

    static func tradeTypeCount(_ type: TradeType, campuses: Set<Campus>, in listings: [ListingItem]) -> Int {
        listings.filter { campuses.contains($0.campus) && $0.tradeType == type }.count
    }
}
