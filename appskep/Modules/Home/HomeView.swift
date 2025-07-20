//
//  HomeView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var authManager: AuthManager
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Text("hai")
        }
      }
    }
  }
}

#Preview {
  HomeView()
    .environmentObject(AuthManager.shared)
}

