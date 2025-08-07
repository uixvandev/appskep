//
//  ChangePasswordViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 07/08/25.
//

import Foundation

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmNewPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPasswordChanged = false
    
    // Validation states
    @Published var showCurrentPasswordError = false
    @Published var showNewPasswordError = false
    @Published var showConfirmPasswordError = false
    
    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmNewPassword
    }
    
    var currentPasswordError: String? {
        guard showCurrentPasswordError else { return nil }
        if currentPassword.isEmpty {
            return "Password saat ini wajib diisi"
        }
        return nil
    }
    
    var newPasswordError: String? {
        guard showNewPasswordError else { return nil }
        if newPassword.isEmpty {
            return "Password baru wajib diisi"
        } else if newPassword.count < 6 {
            return "Password minimal 6 karakter"
        } else if newPassword == currentPassword {
            return "Password baru harus berbeda dari password saat ini"
        }
        return nil
    }
    
    var confirmPasswordError: String? {
        guard showConfirmPasswordError else { return nil }
        if confirmNewPassword.isEmpty {
            return "Konfirmasi password wajib diisi"
        } else if confirmNewPassword != newPassword {
            return "Konfirmasi password tidak cocok"
        }
        return nil
    }
    
    func validateFields() {
        showCurrentPasswordError = currentPassword.isEmpty
        showNewPasswordError = newPassword.isEmpty || newPassword.count < 6 || newPassword == currentPassword
        showConfirmPasswordError = confirmNewPassword.isEmpty || confirmNewPassword != newPassword
    }
    
    func changePassword() async {
        validateFields()
        
        guard isFormValid else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        isPasswordChanged = false
        
        let request = ChangePasswordRequest(
            current_password: currentPassword,
            new_password: newPassword
        )
        
        do {
            let bodyData = try JSONEncoder().encode(request)
            
            let response: ChangePasswordResponse = try await APIService.shared.performRequest(
                endpoint: .changePassword,
                method: .PUT,
                body: bodyData,
                responseType: ChangePasswordResponse.self
            )
            
            if response.success {
                isPasswordChanged = true
                // Clear form after successful change
                currentPassword = ""
                newPassword = ""
                confirmNewPassword = ""
                resetValidationStates()
            } else {
                errorMessage = response.message
            }
        } catch APIError.serverError(let message) {
            if message.contains("current password") || message.contains("password saat ini") || message.contains("incorrect") {
                errorMessage = "Password saat ini tidak benar"
            } else {
                errorMessage = message
            }
        } catch {
            errorMessage = "Gagal mengubah password: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetForm() {
        currentPassword = ""
        newPassword = ""
        confirmNewPassword = ""
        resetValidationStates()
        errorMessage = nil
        isPasswordChanged = false
    }
    
    private func resetValidationStates() {
        showCurrentPasswordError = false
        showNewPasswordError = false
        showConfirmPasswordError = false
    }
}
