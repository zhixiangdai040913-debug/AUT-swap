import Foundation
import FirebaseAuth

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentEmail: String?
    @Published private(set) var currentUserId: String?
    @Published private(set) var currentProfile: UserProfile?
    @Published private(set) var isAuthReady = false

    private let authService: AuthService
    private let userRepository: UserRepository
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var didStartListening = false

    var accountType: AUTAccountType? {
        currentEmail.flatMap(AUTAccountType.init(email:))
    }

    var currentSeller: Seller {
        if AppConfig.useSampleData {
            var seller = MockSellers.currentUser
            if let email = currentEmail {
                seller = Seller(
                    id: currentUserId ?? MockSellers.currentUser.id,
                    name: UserProfile.displayName(from: email),
                    isVerifiedStudent: true,
                    rating: seller.rating,
                    reviewCount: seller.reviewCount
                )
            }
            return seller
        }
        if let profile = currentProfile {
            return profile.asSeller()
        }
        let email = currentEmail ?? "student@autuni.ac.nz"
        return Seller(
            id: currentUserId ?? "unknown",
            name: UserProfile.displayName(from: email),
            isVerifiedStudent: true,
            rating: 5.0,
            reviewCount: 0
        )
    }

    init(
        authService: AuthService = .shared,
        userRepository: UserRepository = .shared
    ) {
        self.authService = authService
        self.userRepository = userRepository
    }

    deinit {
        if let authHandle {
            AuthService.shared.removeStateListener(authHandle)
        }
    }

    /// Call once the app UI is up (Firebase is already configured).
    func startAuthListeningIfNeeded() {
        guard !didStartListening else { return }
        didStartListening = true

        if AppConfig.useSampleData {
            // Phase 1: local mock session only. Clear any leftover Firebase Auth
            // user so favorites / listings never mix sample UIDs with a real Auth UID.
            try? authService.signOut()
            isAuthReady = true
            return
        }

        authHandle = authService.addStateListener { [weak self] user in
            Task { @MainActor in
                await self?.applyAuthUser(user)
            }
        }
    }

    func markReadyIfStillWaiting() {
        guard !isAuthReady else { return }
        if AppConfig.useSampleData {
            isAuthReady = true
            return
        }
        isAuthenticated = authService.isSignedIn
        currentUserId = authService.currentUserId
        currentEmail = authService.currentEmail?.lowercased()
        isAuthReady = true
    }

    private func applyAuthUser(_ user: User?) async {
        guard let user else {
            isAuthenticated = false
            currentEmail = nil
            currentUserId = nil
            currentProfile = nil
            isAuthReady = true
            return
        }

        currentUserId = user.uid
        currentEmail = user.email?.lowercased()
        isAuthenticated = true

        if let profile = await userRepository.fetchProfileIfExists(uid: user.uid) {
            currentProfile = profile
        } else if let email = user.email, let type = AUTAccountType(email: email) {
            currentProfile = try? await userRepository.upsertProfile(
                uid: user.uid,
                email: email,
                accountType: type
            )
        }

        isAuthReady = true
    }

    func signIn(email: String, password: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if AppConfig.useSampleData {
            applySampleSession(email: trimmed)
            return
        }
        _ = try await authService.signIn(email: trimmed, password: password)
    }

    func register(email: String, password: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let type = AUTAccountType(email: trimmed) else {
            throw AuthServiceError.underlying("Please use a valid AUT email.")
        }
        if AppConfig.useSampleData {
            applySampleSession(email: trimmed, accountType: type)
            return
        }
        let user = try await authService.register(email: trimmed, password: password)
        currentProfile = try await userRepository.upsertProfile(
            uid: user.uid,
            email: trimmed,
            accountType: type
        )
    }

    func signOut() {
        if AppConfig.useSampleData {
            isAuthenticated = false
            currentEmail = nil
            currentUserId = nil
            currentProfile = nil
            isAuthReady = true
            return
        }
        do {
            try authService.signOut()
        } catch {
            isAuthenticated = false
            currentEmail = nil
            currentUserId = nil
            currentProfile = nil
            isAuthReady = true
        }
    }

    private func applySampleSession(email: String, accountType: AUTAccountType? = nil) {
        let type = accountType ?? AUTAccountType(email: email) ?? .student
        currentEmail = email
        currentUserId = MockSellers.currentUser.id
        currentProfile = UserProfile(
            id: MockSellers.currentUser.id,
            email: email,
            displayName: UserProfile.displayName(from: email),
            campus: .city,
            accountType: type == .student ? "student" : "staff",
            createdAt: Date()
        )
        isAuthenticated = true
        isAuthReady = true
    }
}
