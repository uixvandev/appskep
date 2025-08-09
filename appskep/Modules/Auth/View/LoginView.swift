//
//  LoginView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegister = false
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon Section
            Image("IconLogin")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 86, height: 86)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Title Section
            VStack(spacing: 8) {
                Text("Selamat Datang Kembali!")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Ayo lanjutkan perjalanan belajarmu dan capai kompetensi maksimal bersama Appskep.")
                    .font(.body)
                    .foregroundStyle(.neutral90)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Form Section
            OutlineTextField(
                text: $viewModel.email,
                placeholder: "Masukkan Email",
                fieldType: .text,
                validation: { $0.isEmpty ? "Email tidak boleh kosong" : nil }
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            
            OutlineTextField(
                text: $viewModel.password,
                placeholder: "Masukkan Password",
                fieldType: .secure,
                validation: { $0.count < 6 ? "Minimal 6 karakter" : nil }
            )
            
            // Button Section
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    CustomLongButton(
                        title: "Masuk",
                        titleColor: .white,
                        bgButtonColor: viewModel.isFormValid ? .main : .neutral60
                    )
                }
                .disabled(!viewModel.isFormValid)
            }
            
            // Forgot Password Link
            NavigationLink {
                // TODO: Implement Forgot Password View
                Text("Forgot Password View")
            } label: {
                Text("Lupa Password")
                    .font(.headline)
                    .foregroundStyle(.main)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Register Link
            Button {
                showRegister = true
            } label: {
                HStack {
                    Text("Belum memiliki akun?")
                        .font(.body)
                        .foregroundColor(.neutral90)
                    Text("Daftar")
                        .font(.body)
                        .foregroundColor(.main)
                        .underline(true)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .alert("Login Gagal", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.showError) { _, newValue in
            showErrorAlert = newValue
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

#Preview {
    // Wrap in NavigationStack for preview only
    NavigationStack {
        LoginView()
    }
}
