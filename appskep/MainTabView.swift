//
//  MainTabView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedIndex: Int = 0
    @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                let iconName = (selectedIndex == 0) ? "HomeBold" : "Home"
                Image(iconName)
                Text("Beranda")
            }
            .tag(0)
            
            NavigationStack {
                SearchClassView()
            }
            .tabItem {
                let iconName = (selectedIndex == 1) ? "SearchBold" : "Search"
                Image(iconName)
                Text("Search")
            }
            .tag(1)
            
            NavigationStack {
                MyClassView()
            }
            .tabItem {
                let iconName = (selectedIndex == 2) ? "PaperBold" : "Paper"
                Image(iconName)
                Text("Kelas saya")
            }
            .tag(2)
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                let iconName = (selectedIndex == 3) ? "ProfileBold" : "Profile"
                Image(iconName)
                Text("Profil")
            }
            .tag(3)
        }
        .tint(.main)
        // Try Out Modal
        .fullScreenCover(isPresented: $tryOutCoordinator.isShowingTryOut) {
            if let tryOutId = tryOutCoordinator.currentTryOutId {
                TryOutView(tryOutId: tryOutId)
                    .environmentObject(tryOutCoordinator)
            }
        }
        // Result Modal
        .fullScreenCover(isPresented: $tryOutCoordinator.isShowingResult) {
            if let result = tryOutCoordinator.tryOutResult {
                TryOutResultView(result: result)
                    .environmentObject(tryOutCoordinator)
            }
        }
        // Pembahasan Modal - Add this
        .fullScreenCover(isPresented: $tryOutCoordinator.isShowingPembahasan) {
            if let tryOutId = tryOutCoordinator.currentPembahasanTryOutId {
                NavigationStack {
                    PembahasanView(tryOutId: tryOutId)
                        .environmentObject(tryOutCoordinator)
                }
            }
        }
        // Auto switch to home tab when returning from try out
        .onChange(of: tryOutCoordinator.isShowingResult) { _, isShowing in
            if !isShowing && !tryOutCoordinator.isShowingTryOut {
                print("🏠 Auto-switching to home tab")
                selectedIndex = 0
            }
        }
        .onChange(of: tryOutCoordinator.isShowingTryOut) { _, isShowing in
            if !isShowing && !tryOutCoordinator.isShowingResult {
                print("🏠 Auto-switching to home tab")
                selectedIndex = 0
            }
        }
        // Auto switch to home tab when returning from pembahasan - Add this
        .onChange(of: tryOutCoordinator.isShowingPembahasan) { _, isShowing in
            if !isShowing {
                print("🏠 Auto-switching to home tab from pembahasan")
                selectedIndex = 0
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
        .environmentObject(TryOutCoordinator())
}
