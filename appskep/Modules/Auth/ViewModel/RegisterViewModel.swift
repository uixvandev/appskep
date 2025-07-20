import Foundation

enum RegisterAlertType: Equatable {
    case none
    case success
    case error(String)

    static func == (lhs: RegisterAlertType, rhs: RegisterAlertType) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none), (.success, .success):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var alertType: RegisterAlertType = .none
    
    private let authManager = AuthManager.shared
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        isValidEmail(email) &&
        password.count >= 6
    }
    
    func register() async {
        alertType = .none // Reset dulu

        guard isFormValid else {
            alertType = .error("Silakan isi semua field dengan benar")
            return
        }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await authManager.register(
                name: name,
                email: email,
                password: password
            )
            
            if response.success {
                alertType = .success
            } else {
                alertType = .error(response.error ?? response.message)
            }
        } catch {
            alertType = .error(error.localizedDescription)
        }
    }
    
    func resetForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
