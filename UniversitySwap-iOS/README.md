# UniversitySwap (iOS)

AUT campus marketplace demo — SwiftUI + Firebase (Auth / Firestore / Storage).

## Open & run

1. Open **`UniversitySwap-iOS/UniversitySwap.xcodeproj`** (not the parent macOS `AUT Swap App.xcodeproj`).
2. Select scheme **UniversitySwap** and an iPhone simulator.
3. Press **⌘R**.

Requires Xcode with iOS Simulator. Firebase iOS SDK is pinned via SPM (**10.24.0**).

## Demo mode (default)

`AppConfig.useSampleData = true` in `UniversitySwap/App/AppConfig.swift`.

| Area | Behaviour |
|------|-----------|
| Login | Any `@autuni.ac.nz` / `@aut.ac.nz` email + password (6+ chars). No Firebase Auth session. |
| Home | Seeded **sample** listings from `MockListings` (banner on Home). |
| Publish | Saves into the in-memory `ListingStore` only (`sample-…` IDs). |
| Favorites | In-memory per session. |
| Messages | In-memory mock conversations — **not** Firestore chat. |

Firebase is still configured at launch (`GoogleService-Info.plist`); sample mode simply avoids live Auth/Firestore writes for a stable classroom demo.

## Suggested 3-minute walkthrough

1. Log in with an AUT email.
2. Browse Home → open a listing → favorite (heart).
3. Profile → Favorites / My Listings.
4. Tab bar **+** → publish an item → confirm it appears on Home.
5. Messages → open a demo conversation (local only).

## Not in this demo

- Real-time Firestore chat / push notifications
- Transactions / payments
- Deployed Firestore/Storage rules (proposed files live under `firebase/` — do not assume they are live)
- Live Firebase Auth unless you set `useSampleData = false` **and** enable Email/Password in Firebase Console

## Source layout

- `UniversitySwap/App` — entry, config, tabs, auth gate
- `UniversitySwap/Features` — screens (Login, Home, Create, Favorites, …)
- `UniversitySwap/Services` — Auth, Listing, Favorites, Storage, Chat stores
- `UniversitySwap/firebase` — proposed security rules (documentation only)
