//
//  ProfileView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Info Header
                    userInfoHeader

                    // Menu Options
                    VStack(spacing: 16) {
                        NavigationLink(destination: TryOutHistoryView()) {
                            ProfileRowView(iconName: "clock", title: "Riwayat Try Out")
                        }
                        
                        NavigationLink(destination: Text("Transaksi View")) {
                            ProfileRowView(iconName: "creditcard", title: "Transaksi")
                        }
                        
                        NavigationLink(destination: Text("Keamanan & Kata Sandi View")) {
                            ProfileRowView(iconName: "lock.shield", title: "Keamanan & Kata Sandi")
                        }
                    }
                    
                    // Logout Button
                    logoutButton
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profil")
            .background(Color(.systemGray6).ignoresSafeArea())
            .alert("Konfirmasi Keluar", isPresented: $showLogoutConfirmation) {
                Button("Batal", role: .cancel) { }
                Button("Keluar", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Apakah Anda yakin ingin keluar dari akun Anda?")
            }
        }
    }

    private var userInfoHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(authManager.currentUser?.name ?? "Nama Pengguna")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(authManager.currentUser?.email ?? "email@pengguna.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
    }

    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Keluar")
                Spacer()
            }
            .font(.headline)
            .foregroundColor(.red)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red, lineWidth: 1)
            )
        }
    }
}

// Reusable row view for profile options
struct ProfileRowView: View {
    let iconName: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(.main)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .foregroundColor(.primary)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
  ProfileView()
    .environmentObject(AuthManager.shared)
}
