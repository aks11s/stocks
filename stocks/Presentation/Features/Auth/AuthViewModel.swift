import Foundation

enum AuthInputMode {
    case phone, email
}

// Auth is a dummy screen — no backend, just sets isAuthenticated in UserDefaults
final class AuthViewModel {

    private(set) var inputMode: AuthInputMode = .phone

    var onInputModeChanged: ((AuthInputMode) -> Void)?
    var onSuccess: (() -> Void)?
    var onValidationError: ((String) -> Void)?

    var fieldLabel: String {
        inputMode == .phone ? "Mobile Number" : "Email"
    }

    var fieldPlaceholder: String {
        inputMode == .phone ? "Enter your mobile" : "Enter your email"
    }

    var toggleTitle: String {
        inputMode == .phone ? "Sign in with email" : "Sign in with mobile"
    }

    // MARK: - Actions

    func toggleInputMode() {
        inputMode = inputMode == .phone ? .email : .phone
        onInputModeChanged?(inputMode)
    }

    func signIn(input: String, password: String) {
        guard validate(input: input, password: password) else { return }
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        onSuccess?()
    }

    // MARK: - Validation

    private func validate(input: String, password: String) -> Bool {
        switch inputMode {
        case .phone:
            // input is masked (+7 (XXX) XXX-XX-XX), so count only digits after the country code
            var digits = input.filter { $0.isNumber }
            if digits.hasPrefix("7") { digits = String(digits.dropFirst()) }
            if digits.count < 10 {
                onValidationError?("Enter a valid phone number (10 digits required)")
                return false
            }
        case .email:
            let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
            if input.range(of: regex, options: .regularExpression) == nil {
                onValidationError?("Enter a valid email address")
                return false
            }
        }
        if password.count < 6 {
            onValidationError?("Password must be at least 6 characters")
            return false
        }
        return true
    }
}
