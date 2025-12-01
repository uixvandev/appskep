//
//  RegisterView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI
import UIKit

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isCheckPolicy = false
    @State private var startExitAnimation = false
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                titleSection
                formSection
                termsSection
                actionSection
                loginSection
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert, content: buildAlert)
        .onChange(of: viewModel.alertType) { _, type in
            showAlert = type != .none
        }
    }

    private var headerSection: some View {
        Image("IconRegister")
            .resizable()
            .scaledToFit()
            .frame(width: 86, height: 86)
            .clipped()
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity.combined(with: .offset(y: -20)))
            .opacity(startExitAnimation ? 0 : 1)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daftar & Mulai Perjalananmu!")
                .font(.title)
                .fontWeight(.bold)

            Text("Gabung bersama ribuan pengguna APPSKEP, siapkan UKOM metode efektif dan interaktif.")
                .font(.body)
                .foregroundStyle(.gray)
        }
        .opacity(startExitAnimation ? 0 : 1)
        .offset(y: startExitAnimation ? -10 : 0)
    }

    private var formSection: some View {
        Group {
            OutlineTextField(
                text: $viewModel.name,
                placeholder: "Nama",
                fieldType: .text,
                validation: { $0.isEmpty ? "Nama tidak boleh kosong" : nil }
            )
            .textInputAutocapitalization(.words)

            OutlineTextField(
                text: $viewModel.email,
                placeholder: "Email",
                fieldType: .text,
                validation: { $0.isEmpty ? "Email tidak boleh kosong" : nil }
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)

            OutlineTextField(
                text: $viewModel.password,
                placeholder: "Password",
                fieldType: .secure,
                validation: { $0.count < 6 ? "Minimal 6 karakter" : nil },
                textContentType: .newPassword
            )

            OutlineTextField(
                text: $viewModel.confirmPassword,
                placeholder: "Konfirmasi Password",
                fieldType: .secure,
                validation: {
                    if $0.isEmpty { return "Konfirmasi password tidak boleh kosong" }
                    if $0 != viewModel.password { return "Password tidak sama" }
                    return nil
                },
                textContentType: .newPassword
            )
        }
        .opacity(startExitAnimation ? 0 : 1)
    }

    private var termsSection: some View {
        HStack(spacing: 8) {
            Image(systemName: isCheckPolicy ? "checkmark.square.fill" : "square")
                .onTapGesture { isCheckPolicy.toggle() }
                .foregroundStyle(.main)
                .font(.largeTitle)

            Text("Saya menyetujui **[Syarat dan ketentuan](https://example.com)** serta **[Kebijakan Privasi](https://example.com)** Appskep.")
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(startExitAnimation ? 0 : 1)
    }

    private var actionSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().padding()
            } else {
                Button {
                    Task { await registerWithAnimation() }
                } label: {
                    CustomLongButton(
                        title: "Daftar",
                        titleColor: .white,
                        bgButtonColor: (isCheckPolicy && viewModel.isFormValid) ? .main : .main.opacity(0.5)
                    )
                }
                .disabled(!isCheckPolicy || !viewModel.isFormValid)
            }
        }
        .opacity(startExitAnimation ? 0 : 1)
    }

    private var loginSection: some View {
        HStack {
            Text("Sudah memiliki akun?")
                .foregroundColor(.gray)
            Button("Masuk") { dismiss() }
                .foregroundColor(.main)
        }
        .opacity(startExitAnimation ? 0 : 1)
    }

    private func buildAlert() -> Alert {
        switch viewModel.alertType {
        case .success:
            return Alert(
                title: Text("Registrasi Berhasil"),
                message: Text("User registered successfully"),
                dismissButton: .default(Text("OK")) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        startExitAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        dismiss()
                        viewModel.resetForm()
                        startExitAnimation = false
                    }
                }
            )
        case .error(let msg):
            return Alert(
                title: Text("Registrasi Gagal"),
                message: Text(msg),
                dismissButton: .default(Text("OK"))
            )
        case .none:
            return Alert(title: Text(""))
        }
    }

    private func registerWithAnimation() async {
        await viewModel.register()
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
