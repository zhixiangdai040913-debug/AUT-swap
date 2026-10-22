import Foundation

enum AUTAccountType {
    case student
    case staff

    static let studentDomain = "autuni.ac.nz"
    static let staffDomain = "aut.ac.nz"

    init?(email: String) {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }

        let localPart = String(parts[0])
        let domain = parts[1].lowercased()

        let allowedLocal = "^[A-Za-z0-9](?:[A-Za-z0-9._%+-]*[A-Za-z0-9])?$"
        guard localPart.range(of: allowedLocal, options: .regularExpression) != nil,
              !localPart.contains("..")
        else { return nil }

        switch domain {
        case Self.studentDomain: self = .student
        case Self.staffDomain: self = .staff
        default: return nil
        }
    }
}

enum LoginError: Equatable {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case weakPassword
    case firebase(String)

    var message: String {
        switch self {
        case .emptyEmail:
            return "Please enter your AUT email."
        case .invalidEmail:
            return "Please use your AUT email ending in @autuni.ac.nz (students) or @aut.ac.nz (staff)."
        case .emptyPassword:
            return "Please enter your password."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .firebase(let message):
            return message
        }
    }

    var isEmailError: Bool {
        switch self {
        case .emptyEmail, .invalidEmail: return true
        default: return false
        }
    }
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published private(set) var isLoading = false
    @Published private(set) var error: LoginError?

    func clearError() {
        error = nil
    }

    /// Validates fields locally. Returns trimmed email on success.
    func validatedCredentials(requireStrongPassword: Bool = false) -> (email: String, password: String)? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            error = .emptyEmail
            return nil
        }
        guard AUTAccountType(email: trimmedEmail) != nil else {
            error = .invalidEmail
            return nil
        }
        if password.isEmpty {
            error = .emptyPassword
            return nil
        }
        if requireStrongPassword && password.count < 6 {
            error = .weakPassword
            return nil
        }

        error = nil
        return (trimmedEmail, password)
    }

    func performLogin(using appState: AppState) async -> Bool {
        guard let credentials = validatedCredentials() else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            try await appState.signIn(email: credentials.email, password: credentials.password)
            return true
        } catch let authError {
            self.error = .firebase(authError.localizedDescription)
            return false
        }
    }

    func performRegister(using appState: AppState) async -> Bool {
        guard let credentials = validatedCredentials(requireStrongPassword: true) else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            try await appState.register(email: credentials.email, password: credentials.password)
            return true
        } catch let authError {
            self.error = .firebase(authError.localizedDescription)
            return false
        }
    }
}
