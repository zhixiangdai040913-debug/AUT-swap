# UniversitySwap — UI Style Guide (1 page)

Extracted from the current iOS SwiftUI implementation (`AppTheme`, `ListingCard`, Login / Publish buttons).

---

## Colors

| Role | Hex | Notes |
|------|-----|--------|
| **Primary / brand** | `#FF7A1C` | Main accent (CTAs, price, selected tab, Publish “+”). Not AUT navy — marketplace orange. |
| **Text primary** | `#1D2740` | Titles and main body text |
| **Text secondary / tertiary** | `#4A5468` / `#7C8597` | Supporting labels, captions |
| **Verified badge** | `#4F6FD8` | “AUT Student / Staff” chip (blue) |
| **Error / logout** | `#F04438` | Validation errors, Log Out |

### Trade-type badge colours (on listing cards)

| Trade type | Colour | Hex | In code |
|------------|--------|-----|---------|
| **Giveaway** | Green | `#3DBE5C` | `AppTheme.giveawayGreen` |
| **Sell** | Orange | `#FF7A1C` | `AppTheme.brandOrange` |
| **Swap** | Orange | `#FF7A1C` | Same as Sell in the current build |

White capsule label, 11 pt semibold text on the badge.

---

## Typography

- **Font family:** San Francisco (iOS system font) — **SF Pro** via SwiftUI `.font(.system(...))`. No custom font files.
- **Typical sizes:**
  - Screen titles: ~22 pt **bold**
  - Card title: 14 pt **semibold** (max 2 lines)
  - Price: 18 pt **bold** (orange)
  - Meta (campus / distance): 12 pt regular, tertiary grey
  - Primary button label: 17 pt **semibold**, white
  - Trade badge: 11 pt **semibold**, white

---

## Components

### Listing Card

White card, **14 pt** continuous corner radius, light shadow.

1. **Image** — 4:3 photo (or category placeholder)  
2. **Trade badge** — top-left capsule (Give Away / Swap / Sell)  
3. **Title** — up to 2 lines  
4. **Price line** — `$N` (orange), or “Free · Pickup only”, or “Open to swap”  
5. **Location** — pin icon + campus · distance  
6. **Favorite** — heart + like count (bottom-right)

Used on Home, Categories, Favorites, and My Listings.

### Button (primary)

- Shape: **capsule** (pill) or rounded rectangle (~14 pt) for form actions  
- Fill: brand orange `#FF7A1C`  
- Label: white, semibold  
- Examples: **Log In**, **Sign Up**, **Apply** (filters), **Post** / **Next** (create listing), center **Publish (+)** on the tab bar  

Secondary actions use orange **text only** (e.g. “Forgot Password?”, “Try Again”). Destructive actions use red (e.g. **Log Out**).

---

*Source: `Shared/Theme/AppTheme.swift`, `Shared/Theme/ListingStyle.swift`, `Features/Home/ListingCard.swift`.*
