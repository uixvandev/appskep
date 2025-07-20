//
//  LoginViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    private let authManager = AuthManager.shared
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && isValidEmail(email)
    }
    
    func login() async {
        guard isFormValid else {
            showErrorMessage("Please enter valid email and password")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let response = try await authManager.login(email: email, password: password)
            
            if !response.success {
                showErrorMessage(response.error ?? response.message)
            }
            // Success akan ditangani oleh AuthManager dan mengupdate isAuthenticated
        } catch {
            showErrorMessage(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
