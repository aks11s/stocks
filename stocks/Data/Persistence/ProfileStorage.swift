import Foundation

// Single source of truth for user profile data — all fields are optional
// because a fresh install has nothing saved yet.
final class ProfileStorage {

    static let shared = ProfileStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let username    = "profile.username"
        static let email       = "profile.email"
        static let phone       = "profile.phone"
        static let password    = "profile.passwordHash"
        static let avatarImage = "profile.avatarImageData"
    }

    var username: String? {
        get { defaults.string(forKey: Key.username) }
        set { defaults.set(newValue, forKey: Key.username) }
    }

    var email: String? {
        get { defaults.string(forKey: Key.email) }
        set { defaults.set(newValue, forKey: Key.email) }
    }

    var phone: String? {
        get { defaults.string(forKey: Key.phone) }
        set { defaults.set(newValue, forKey: Key.phone) }
    }

    var avatarImageData: Data? {
        get { defaults.data(forKey: Key.avatarImage) }
        set { defaults.set(newValue, forKey: Key.avatarImage) }
    }

    // Store only a simple hash — never keep plaintext passwords on device
    var passwordHash: String? {
        get { defaults.string(forKey: Key.password) }
        set { defaults.set(newValue, forKey: Key.password) }
    }

    // Called right after sign-in to pre-populate whichever field the user authenticated with
    func saveAuthCredentials(phone: String? = nil, email: String? = nil, password: String) {
        if let phone, !phone.isEmpty { self.phone = phone }
        if let email, !email.isEmpty { self.email = email }
        self.passwordHash = password.simpleHash
    }

    func save(username: String?, email: String?, phone: String?, password: String?) {
        self.username = username?.isEmpty == false ? username : nil
        self.email    = email?.isEmpty    == false ? email    : nil
        self.phone    = phone?.isEmpty    == false ? phone    : nil
        if let raw = password, !raw.isEmpty {
            self.passwordHash = raw.simpleHash
        }
    }
}

// Lightweight deterministic hash — good enough for local storage,
// not intended as a cryptographic solution.
private extension String {
    var simpleHash: String {
        String(self.unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ UInt64($1.value) })
    }
}
