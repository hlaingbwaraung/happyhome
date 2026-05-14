import Foundation
import Combine
import CryptoKit

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var session: AuthSession?
    @Published var isLoading = false
    @Published var message: String?

    private let sessionKey = "happyhome.auth.session"
    private let accountStore = AuthAccountStore()

    var isSignedIn: Bool {
        session != nil
    }

    var signedInAccount: AuthAccount? {
        guard let session else {
            return nil
        }

        return accountStore.account(matching: session.accountID)
    }

    init() {
        accountStore.seedAdminAccountIfNeeded()
        restoreSession()
    }

    func signUp(identifier: String, password: String, fullName: String, phoneNumber: String, birthday: Date) async {
        await authenticate(
            mode: .signUp,
            identifier: identifier,
            password: password,
            fullName: fullName,
            phoneNumber: phoneNumber,
            birthday: birthday
        )
    }

    func signIn(identifier: String, password: String) async {
        await authenticate(mode: .signIn, identifier: identifier, password: password)
    }

    func signOut() {
        session = nil
        message = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    private func authenticate(
        mode: AuthMode,
        identifier: String,
        password: String,
        fullName: String = "",
        phoneNumber: String = "",
        birthday: Date? = nil
    ) async {
        let normalizedID = AuthAccount.normalizedIdentifier(identifier)
        guard normalizedID.count >= 3 else {
            message = "Enter an ID or email with at least 3 characters."
            return
        }

        if mode == .signUp {
            guard fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
                message = "Enter your name."
                return
            }

            guard phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6 else {
                message = "Enter a valid phone number."
                return
            }
        }

        guard password.count >= 8 else {
            message = "Use a password with at least 8 characters."
            return
        }

        isLoading = true
        message = nil

        do {
            let account: AuthAccount

            switch mode {
            case .signIn:
                account = try accountStore.signIn(identifier: normalizedID, password: password)
                message = "Logged in as \(account.displayName)."
            case .signUp:
                account = try accountStore.signUp(
                    identifier: normalizedID,
                    password: password,
                    fullName: fullName,
                    phoneNumber: phoneNumber,
                    birthday: birthday ?? Date()
                )
                message = "Account created for \(account.displayName)."
            }

            let newSession = AuthSession(accountID: account.id, createdAt: Date())
            session = newSession
            saveSession(newSession)
        } catch {
            message = error.localizedDescription
        }

        isLoading = false
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let savedSession = try? JSONDecoder().decode(AuthSession.self, from: data),
              accountStore.account(matching: savedSession.accountID) != nil else {
            return
        }

        session = savedSession
    }

    private func saveSession(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else {
            return
        }

        UserDefaults.standard.set(data, forKey: sessionKey)
    }
}

enum AuthMode: Hashable {
    case signIn
    case signUp
}

struct AuthSession: Codable {
    let accountID: UUID
    let createdAt: Date
}

enum AccountRole: String, Codable {
    case admin
    case user
}

struct AuthAccount: Codable, Identifiable {
    let id: UUID
    let identifier: String
    let passwordHash: String
    let salt: String
    let role: AccountRole
    let createdAt: Date
    let fullName: String
    let phoneNumber: String
    let birthday: Date?

    init(
        id: UUID,
        identifier: String,
        passwordHash: String,
        salt: String,
        role: AccountRole,
        createdAt: Date,
        fullName: String,
        phoneNumber: String,
        birthday: Date?
    ) {
        self.id = id
        self.identifier = identifier
        self.passwordHash = passwordHash
        self.salt = salt
        self.role = role
        self.createdAt = createdAt
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.birthday = birthday
    }

    var displayName: String {
        if role == .admin {
            return "\(identifier) (Admin)"
        }

        return fullName.isEmpty ? identifier : fullName
    }

    static func normalizedIdentifier(_ identifier: String) -> String {
        identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    func verifies(password: String) -> Bool {
        passwordHash == Self.passwordHash(for: password, salt: salt)
    }

    static func make(
        identifier: String,
        password: String,
        role: AccountRole,
        fullName: String = "",
        phoneNumber: String = "",
        birthday: Date? = nil
    ) -> AuthAccount {
        let salt = UUID().uuidString

        return AuthAccount(
            id: UUID(),
            identifier: normalizedIdentifier(identifier),
            passwordHash: passwordHash(for: password, salt: salt),
            salt: salt,
            role: role,
            createdAt: Date(),
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            birthday: birthday
        )
    }

    private static func passwordHash(for password: String, salt: String) -> String {
        let data = Data("\(salt):\(password)".utf8)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case passwordHash
        case salt
        case role
        case createdAt
        case fullName
        case phoneNumber
        case birthday
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        identifier = try container.decode(String.self, forKey: .identifier)
        passwordHash = try container.decode(String.self, forKey: .passwordHash)
        salt = try container.decode(String.self, forKey: .salt)
        role = try container.decode(AccountRole.self, forKey: .role)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
    }
}

enum AuthError: LocalizedError {
    case accountAlreadyExists
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .accountAlreadyExists:
            return "That ID is already registered. Login instead."
        case .invalidCredentials:
            return "The ID or password is incorrect."
        }
    }
}

private final class AuthAccountStore {
    private let accountsKey = "happyhome.auth.accounts"
    private let adminIdentifier = "admin"
    private let adminPassword = "HappyHome@2026"

    func seedAdminAccountIfNeeded() {
        var savedAccounts = accounts

        if let adminIndex = savedAccounts.firstIndex(where: { $0.identifier == adminIdentifier }) {
            guard !savedAccounts[adminIndex].verifies(password: adminPassword) else {
                return
            }

            savedAccounts[adminIndex] = AuthAccount.make(
                identifier: adminIdentifier,
                password: adminPassword,
                role: .admin
            )
            save(savedAccounts)
            return
        }

        savedAccounts.append(
            AuthAccount.make(
                identifier: adminIdentifier,
                password: adminPassword,
                role: .admin
            )
        )
        save(savedAccounts)
    }

    func account(matching id: UUID) -> AuthAccount? {
        accounts.first { $0.id == id }
    }

    func signIn(identifier: String, password: String) throws -> AuthAccount {
        guard let account = accounts.first(where: { $0.identifier == identifier }),
              account.verifies(password: password) else {
            throw AuthError.invalidCredentials
        }

        return account
    }

    func signUp(
        identifier: String,
        password: String,
        fullName: String,
        phoneNumber: String,
        birthday: Date
    ) throws -> AuthAccount {
        var savedAccounts = accounts

        guard !savedAccounts.contains(where: { $0.identifier == identifier }) else {
            throw AuthError.accountAlreadyExists
        }

        let account = AuthAccount.make(
            identifier: identifier,
            password: password,
            role: .user,
            fullName: fullName,
            phoneNumber: phoneNumber,
            birthday: birthday
        )
        savedAccounts.append(account)
        save(savedAccounts)
        return account
    }

    private var accounts: [AuthAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let savedAccounts = try? JSONDecoder().decode([AuthAccount].self, from: data) else {
            return []
        }

        return savedAccounts
    }

    private func save(_ accounts: [AuthAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else {
            return
        }

        UserDefaults.standard.set(data, forKey: accountsKey)
    }
}
