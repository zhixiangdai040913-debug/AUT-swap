import Foundation

/// Phase toggle for UniversitySwap.
/// Phase 1 uses in-app sample listings and local auth so the UI can be demoed
/// without Firebase Auth / Firestore being fully configured.
/// FirebaseApp.configure() still runs in AppDelegate either way.
enum AppConfig {
    /// Classroom demo default: local AUT-email login, `MockListings`, in-memory
    /// favorites/chat, and local publish (listing IDs prefixed `sample-`).
    /// Set to `false` only when Firebase Auth Email/Password is enabled and you
    /// intend to use live Firestore/Storage (chat still has no remote backend).
    /// FirebaseApp.configure() still runs either way; this flag does not invent
    /// fake Firebase write successes.
    static let useSampleData = true
}
