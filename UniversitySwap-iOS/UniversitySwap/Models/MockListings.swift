import Foundation

enum MockSellers {
    static let alex = Seller(id: "alex-chen", name: "Alex Chen", isVerifiedStudent: true, rating: 4.8, reviewCount: 12)
    static let jamie = Seller(id: "jamie-lee", name: "Jamie Lee", isVerifiedStudent: true, rating: 4.9, reviewCount: 21)
    static let taylor = Seller(id: "taylor-smith", name: "Taylor Smith", isVerifiedStudent: true, rating: 4.7, reviewCount: 8)
    static let morgan = Seller(id: "morgan-brown", name: "Morgan Brown", isVerifiedStudent: true, rating: 4.6, reviewCount: 15)
    static let casey = Seller(id: "casey-wilson", name: "Casey Wilson", isVerifiedStudent: false, rating: 4.5, reviewCount: 3)

    static let currentUser = alex
    static let all = [alex, jamie, taylor, morgan, casey]

    static func seller(id: String) -> Seller? {
        all.first { $0.id == id }
    }
}

enum MockListings {
    static let all: [Listing] = [
        make("1", image: "listing-macbook-air", "MacBook Air M1 2020",
             "MacBook Air M1 2020, 8G+256G, in good condition. Comes with original charger and box. Used for 1.5 years, no major scratches.",
             850, .sell, .city, .electronics, ["Laptop", "Apple"], 0.4, 12, 30, MockSellers.alex,
             "Same-day pickup preferred", "laptopcomputer",
             gallery: ["laptopcomputer", "keyboard", "powerplug", "shippingbox", "doc.text"]),
        make("2", image: "listing-office-chair", "Office Chair (Good Condition)",
             "Black mesh office chair with adjustable height. Moving out, so it needs a new home. Free to whoever picks it up first.",
             nil, .giveaway, .north, .furniture, ["Chair", "Study"], 0.5, 8, 45, MockSellers.jamie,
             "Pickup only, North campus dorm lobby", "chair.fill"),
        make("3", image: "listing-psychology-textbook", "Textbook - Psychology (2nd Edition)",
             "Introductory psychology textbook, 2nd edition. A few highlighted pages. Happy to swap for a statistics or sociology textbook.",
             20, .swap, .city, .textbooks, ["Psychology", "PSYC101"], 0.8, 5, 60, MockSellers.taylor,
             "Meet at City campus library", "book.closed.fill"),
        make("4", image: "listing-hoodie-black", "Hoodie (Large)",
             "Black AUT hoodie, size L. Worn a few times, washed and in great condition.",
             50, .sell, .south, .clothing, ["Hoodie", "AUT"], 1.2, 14, 90, MockSellers.morgan,
             "Weekday afternoons at South campus", "tshirt.fill"),
        make("5", image: "listing-calculus-textbook", "Calculus Early Transcendentals 3rd Ed",
             "Clean copy with minimal highlighting. Required for MATH102.",
             45, .sell, .city, .textbooks, ["Maths", "MATH102"], 0.6, 7, 120, MockSellers.alex,
             "Meet at City campus library", "books.vertical.fill"),
        make("6", image: "listing-desk-lamp", "Desk Lamp + Study Organiser",
             "LED desk lamp with USB port plus a pen holder tray. Free to a good home.",
             nil, .giveaway, .city, .other, ["Lamp", "Study"], 1.0, 3, 150, MockSellers.casey,
             "Pickup from WZ building foyer", "lamp.desk.fill"),
        make("7", image: "listing-ipad-air", "iPad Air 4 + Apple Pencil",
             "64GB, battery health 92%. Comes with case and 2nd gen Apple Pencil.",
             420, .sell, .city, .electronics, ["Tablet", "Apple"], 1.1, 18, 200, MockSellers.jamie,
             "Same-day pickup preferred", "ipad"),
        make("8", image: "listing-aut-hoodie", "AUT Hoodie (Medium)",
             "Official AUT hoodie, size M, worn twice.",
             25, .sell, .city, .clothing, ["Hoodie", "AUT"], 0.9, 6, 240, MockSellers.taylor,
             "Meet at City campus quad", "tshirt.fill"),
        make("9", image: "listing-desk-chair", "Ergonomic Desk Chair",
             "Adjustable height with good lumbar support. Minor wear on the armrests.",
             55, .sell, .city, .furniture, ["Chair", "Ergonomic"], 1.4, 9, 300, MockSellers.morgan,
             "Pickup only, car recommended", "chair.fill"),
        make("10", image: "listing-graduation-gown", "Graduation Gown + Cap",
             "Size M, dry cleaned after last ceremony.",
             20, .sell, .city, .graduation, ["Gown", "Cap"], 0.7, 4, 360, MockSellers.casey,
             "Meet at City campus", "graduationcap.fill"),
        make("11", image: "listing-study-desk", "IKEA Study Desk",
             "White IKEA desk, 120 x 60 cm. Easy to disassemble.",
             40, .sell, .north, .furniture, ["Desk", "IKEA"], 0.9, 11, 75, MockSellers.alex,
             "Pickup only, North campus", "table.furniture.fill"),
        make("12", image: "listing-graphing-calculator", "Graphic Calculator TI-84",
             "Fully working. Looking to swap for a textbook or backpack.",
             nil, .swap, .north, .electronics, ["Calculator", "Maths"], 1.3, 6, 180, MockSellers.jamie,
             "Meet at North campus library", "function"),
        make("13", image: "listing-mini-fridge", "Mini Fridge - Dorm Size",
             "Compact fridge, perfect for a dorm room. Cleaned and working well.",
             60, .sell, .north, .other, ["Fridge", "Dorm"], 1.6, 10, 260, MockSellers.taylor,
             "Pickup only, car required", "refrigerator.fill"),
        make("14", image: "listing-graduation-stole", "Graduation Stole + Sash",
             "Faculty colours included. Worn once.",
             12, .sell, .north, .graduation, ["Stole", "Sash"], 0.8, 2, 420, MockSellers.morgan,
             "Meet at North campus", "graduationcap.fill"),
        make("15", image: "listing-biology-textbook", "Biology Campbell 12th Ed",
             "Heavy textbook in great condition. Required for BIOL101.",
             50, .sell, .south, .textbooks, ["Biology", "BIOL101"], 0.7, 5, 110, MockSellers.casey,
             "Meet at South campus café", "leaf.fill"),
        make("16", image: "listing-running-shoes", "Nike Running Shoes US 9",
             "Lightly used. Swap for a gym bag or water bottle bundle.",
             nil, .swap, .south, .clothing, ["Shoes", "Nike"], 1.5, 3, 210, MockSellers.alex,
             "Meet at South campus gym", "shoeprint.fill"),
        make("17", image: "listing-microwave", "Microwave 20L",
             "Working microwave, perfect for quick meals between classes. Free.",
             nil, .giveaway, .south, .other, ["Kitchen", "Dorm"], 0.9, 2, 330, MockSellers.jamie,
             "Pickup only, South campus", "microwave.fill"),
        make("18", image: "listing-keyboard-mouse", "Wireless Mouse + Keyboard",
             "Logitech combo, barely used. Batteries included.",
             18, .sell, .south, .electronics, ["Accessories", "Logitech"], 1.1, 4, 400, MockSellers.taylor,
             "Same-day pickup preferred", "keyboard.fill")
    ]

    static func listing(id: String) -> Listing? {
        all.first { $0.id == id }
    }

    private static func make(
        _ id: String,
        image imageName: String,
        _ title: String,
        _ description: String,
        _ price: Double?,
        _ tradeType: TradeType,
        _ campus: Campus,
        _ category: ListingCategory,
        _ extraTags: [String],
        _ distanceKm: Double,
        _ likeCount: Int,
        _ minutesAgo: Double,
        _ seller: Seller,
        _ pickupNote: String,
        _ symbolName: String,
        gallery: [String] = []
    ) -> Listing {
        Listing(
            id: id,
            title: title,
            description: description,
            price: price,
            tradeType: tradeType,
            campus: campus,
            category: category,
            tags: [category.rawValue] + extraTags,
            distanceKm: distanceKm,
            likeCount: likeCount,
            postedAt: Date().addingTimeInterval(-minutesAgo * 60),
            seller: seller,
            pickupNote: pickupNote,
            condition: Self.sampleCondition(for: id, tradeType: tradeType),
            symbolName: symbolName,
            gallerySymbols: gallery,
            imageName: imageName
        )
    }

    private static func sampleCondition(for id: String, tradeType: TradeType) -> String {
        if tradeType == .giveaway { return "Used · Free pickup" }
        switch id {
        case "1", "7": return "Like New"
        case "3", "5", "15": return "Good · Some highlighting"
        case "4", "8": return "Gently used"
        default: return "Good"
        }
    }
}
