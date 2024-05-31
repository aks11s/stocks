import Foundation

// Holds the profile fields. Everything is optional since a fresh install is empty.
final class ProfileStorage {

    static let shared = ProfileStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let username = "profile.username"
        static let email    = "profile.email"
        static let phone    = "profile.phone"
        static let password = "profile.passwordHash"
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

    // keep a hash, not the plaintext password
    var passwordHash: String? {
        get { defaults.string(forKey: Key.password) }
        set { defaults.set(newValue, forKey: Key.password) }
    }

    // call this on sign-in to prefill whatever the user logged in with
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

// tiny deterministic hash, fine for local storage but not real crypto
private extension String {
    var simpleHash: String {
        String(self.unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ UInt64($1.value) })
    }
}
