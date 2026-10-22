import Foundation
import FirebaseFirestore

enum UserRepositoryError: LocalizedError {
    case missingDocument
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .missingDocument:
            return "User profile was not found."
        case .underlying(let message):
            return message
        }
    }
}

final class UserRepository {
    static let shared = UserRepository()

    private var db: Firestore { Firestore.firestore() }
    private var users: CollectionReference { db.collection("users") }

    private init() {}

    func upsertProfile(uid: String, email: String, accountType: AUTAccountType) async throws -> UserProfile {
        let profile = UserProfile(
            id: uid,
            email: email.lowercased(),
            displayName: UserProfile.displayName(from: email),
            campus: nil,
            accountType: accountType == .student ? "student" : "staff",
            createdAt: Date()
        )

        let data: [String: Any] = [
            "email": profile.email,
            "displayName": profile.displayName,
            "accountType": profile.accountType,
            "campus": NSNull(),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            try await users.document(uid).setData(data, merge: true)
            return profile
        } catch {
            throw UserRepositoryError.underlying(error.localizedDescription)
        }
    }

    func fetchProfile(uid: String) async throws -> UserProfile {
        do {
            let snapshot = try await users.document(uid).getDocument()
            guard let data = snapshot.data() else {
                throw UserRepositoryError.missingDocument
            }
            return Self.decode(id: snapshot.documentID, data: data)
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            throw UserRepositoryError.underlying(error.localizedDescription)
        }
    }

    func fetchProfileIfExists(uid: String) async -> UserProfile? {
        try? await fetchProfile(uid: uid)
    }

    static func decode(id: String, data: [String: Any]) -> UserProfile {
        let email = data["email"] as? String ?? ""
        let displayName = data["displayName"] as? String
            ?? UserProfile.displayName(from: email)
        let accountType = data["accountType"] as? String ?? "student"
        let campusRaw = data["campus"] as? String
        let campus = campusRaw.flatMap(Campus.init(rawValue:))
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

        return UserProfile(
            id: id,
            email: email,
            displayName: displayName,
            campus: campus,
            accountType: accountType,
            createdAt: createdAt
        )
    }
}
