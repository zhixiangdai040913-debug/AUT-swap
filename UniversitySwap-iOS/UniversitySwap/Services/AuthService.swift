import Foundation
import FirebaseAuth

enum AuthServiceError: LocalizedError {
    case notAuthenticated
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case network
    case authNotConfigured
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .emailAlreadyInUse:
            return "An account with this email already exists. Try Log In instead."
        case .invalidCredentials:
            return "Incorrect email or password. If you are new, tap Sign Up first."
        case .network:
            return "Network error. Check your connection and try again."
        case .authNotConfigured:
            return "Firebase Authentication is not enabled for this project. Open Firebase Console → Authentication → Get started → enable Email/Password, then try again."
        case .underlying(let message):
            return message
        }
    }

    static func map(_ error: Error) -> AuthServiceError {
        let nsError = error as NSError
        let detail = underlyingDetail(from: nsError).uppercased()

        if detail.contains("CONFIGURATION_NOT_FOUND")
            || detail.contains("OPERATION_NOT_ALLOWED")
            || detail.contains("IDENTITY TOOLKIT")
        {
            return .authNotConfigured
        }

        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode.Code(rawValue: nsError.code)
        else {
            return .underlying(friendlyMessage(from: nsError))
        }

        switch code {
        case .wrongPassword, .userNotFound, .invalidCredential, .invalidEmail:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        case .operationNotAllowed, .internalError:
            // iOS SDK often wraps CONFIGURATION_NOT_FOUND as internalError.
            if detail.contains("CONFIGURATION_NOT_FOUND")
                || detail.contains("OPERATION_NOT_ALLOWED")
                || detail.isEmpty
            {
                return .authNotConfigured
            }
            return .underlying(friendlyMessage(from: nsError))
        default:
            return .underlying(friendlyMessage(from: nsError))
        }
    }

    private static func underlyingDetail(from error: NSError) -> String {
        var parts: [String] = []
        if let reason = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
            parts.append(reason)
        }
        if let desc = error.userInfo[NSLocalizedDescriptionKey] as? String {
            parts.append(desc)
        }
        // Firebase sometimes nests the server payload here.
        for key in ["FIRAuthErrorUserInfoNameKey", "AuthErrorUserInfoNameKey"] {
            if let value = error.userInfo[key] as? String {
                parts.append(value)
            }
        }
        if let underlying = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            parts.append(underlying.localizedDescription)
            if let reason = underlying.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                parts.append(reason)
            }
        }
        parts.append(error.localizedDescription)
        return parts.joined(separator: " | ")
    }

    private static func friendlyMessage(from error: NSError) -> String {
        let detail = underlyingDetail(from: error)
        if detail.localizedCaseInsensitiveContains("internal error") {
            return AuthServiceError.authNotConfigured.errorDescription
                ?? "Authentication failed. Check Firebase Console setup."
        }
        return error.localizedDescription
    }
}

final class AuthService {
    static let shared = AuthService()

    /// Lazily resolved so we never call `Auth.auth()` before `FirebaseApp.configure()`.
    private var auth: Auth { Auth.auth() }

    var currentUserId: String? { auth.currentUser?.uid }
    var currentEmail: String? { auth.currentUser?.email }
    var isSignedIn: Bool { auth.currentUser != nil }

    private init() {}

    @discardableResult
    func addStateListener(_ handler: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        auth.addStateDidChangeListener { _, user in
            handler(user)
        }
    }

    func removeStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        auth.removeStateDidChangeListener(handle)
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            #if DEBUG
            let ns = error as NSError
            print("Auth signIn failed:", ns.domain, ns.code, ns.userInfo)
            #endif
            throw AuthServiceError.map(error)
        }
    }

    func register(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user
        } catch {
            #if DEBUG
            let ns = error as NSError
            print("Auth register failed:", ns.domain, ns.code, ns.userInfo)
            #endif
            throw AuthServiceError.map(error)
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthServiceError.map(error)
        }
    }
}
