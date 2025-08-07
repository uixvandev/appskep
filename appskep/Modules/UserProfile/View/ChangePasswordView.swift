//
//  ChangePasswordView.swift
//  appskep
//
//  Created by irfan wahendra on 07/08/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Info
                    headerSection
                    
                    // Password Form
                    passwordFormSection
                    
                    // Save Button
                    saveButtonSection
                }
                .padding()
            }
            .navigationTitle("Keamanan & Kata Sandi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kembali") {
                        dismiss()
                    }
                    .foregroundColor(.main)
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Berhasil", isPresented: $viewModel.isPasswordChanged) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Password berhasil diubah. Silakan login kembali dengan password baru Anda.")
            }
            .overlay {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                        Text("Mengubah password...")
                            .font(.headline)
                            .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundColor(.main)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ubah Password")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Pastikan password baru Anda aman dan mudah diingat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Security tips
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips Keamanan:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.main)
                
                VStack(alignment: .leading, spacing: 4) {
                    SecurityTipRow(text: "Minimal 6 karakter")
                    SecurityTipRow(text: "Gunakan kombinasi huruf, angka, dan simbol")
                    SecurityTipRow(text: "Jangan gunakan password yang sama dengan akun lain")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var passwordFormSection: some View {
        VStack(spacing: 20) {
            // Current Password
            PasswordField(
                title: "Password Saat Ini",
                text: $viewModel.currentPassword,
                placeholder: "Masukkan password saat ini",
                errorMessage: viewModel.currentPasswordError,
                onEditingChanged: { _ in
                    if viewModel.showCurrentPasswordError {
                        viewModel.showCurrentPasswordError = false
                    }
                }
            )
            
            // New Password
            PasswordField(
                title: "Password Baru",
                text: $viewModel.newPassword,
                placeholder: "Masukkan password baru",
                errorMessage: viewModel.newPasswordError,
                onEditingChanged: { _ in
                    if viewModel.showNewPasswordError {
                        viewModel.showNewPasswordError = false
                    }
                }
            )
            
            // Confirm New Password
            PasswordField(
                title: "Konfirmasi Password Baru",
                text: $viewModel.confirmNewPassword,
                placeholder: "Konfirmasi password baru",
                errorMessage: viewModel.confirmPasswordError,
                onEditingChanged: { _ in
                    if viewModel.showConfirmPasswordError {
                        viewModel.showConfirmPasswordError = false
                    }
                }
            )
        }
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.changePassword()
                }
            }) {
                Text("Ubah Password")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid ? Color.main : Color.gray.opacity(0.5))
                    .cornerRadius(16)
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            
            Button("Reset Form") {
                viewModel.resetForm()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Supporting Views
struct PasswordField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let errorMessage: String?
    let onEditingChanged: (Bool) -> Void
    
    @State private var isSecure = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text, onCommit: {})
                    } else {
                        TextField(placeholder, text: $text, onEditingChanged: onEditingChanged)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color(.systemGray4), lineWidth: 1)
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SecurityTipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ChangePasswordView()
}
