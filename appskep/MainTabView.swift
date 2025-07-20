//
//  MainTabView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct MainTabView: View {
  @State private var selectedIndex: Int = 0
  
  var body: some View {
    TabView(selection: $selectedIndex) {
      HomeView()
        .tabItem {
          let iconName = (selectedIndex == 0) ? "HomeBold" : "Home"
          Image(iconName)
          Text("Beranda")
        }
        .tag(0)
      
      SearchClassView()
        .tabItem {
          let iconName = (selectedIndex == 1) ? "SearchBold" : "Search"
          Image(iconName)
          Text("Search")
        }
        .tag(1)
      
      MyClassView()
        .tabItem {
          let iconName = (selectedIndex == 2) ? "PaperBold" : "Paper"
          Image(iconName)
          Text("Kelas saya")
        }
        .tag(2)
      
      ProfileView()
        .tabItem {
          let iconName = (selectedIndex == 3) ? "ProfileBold" : "Profile"
          Image(iconName)
          Text("Profil")
        }
        .tag(3)
    }
    .tint(.main)
  }
}

#Preview {
  MainTabView()
    .environmentObject(AuthManager.shared)
}
