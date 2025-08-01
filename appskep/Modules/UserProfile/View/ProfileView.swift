//
//  ProfileView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Halaman Profil")
                .font(.title)
            
            Button(action: {
                authManager.logout()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
  ProfileView()
    .environmentObject(AuthManager.shared)
}
