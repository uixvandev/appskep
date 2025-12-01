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
                Text("Cari kelas")
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
        .fullScreenCover(isPresented: Binding(
            get: { tryOutCoordinator.isShowingTryOut && tryOutCoordinator.currentTryOutId != nil },
            set: { newValue in tryOutCoordinator.isShowingTryOut = newValue }
        )) {
            // At this point currentTryOutId is non-nil
            TryOutView(tryOutId: tryOutCoordinator.currentTryOutId!)
                .environmentObject(tryOutCoordinator)
        }
        // Result Modal
        .fullScreenCover(isPresented: Binding(
            get: { tryOutCoordinator.isShowingResult && tryOutCoordinator.tryOutResult != nil },
            set: { newValue in tryOutCoordinator.isShowingResult = newValue }
        )) {
            TryOutResultView(result: tryOutCoordinator.tryOutResult!)
                .environmentObject(tryOutCoordinator)
        }
        // Pembahasan Modal (own local stack is fine for modal-only flow)
        .fullScreenCover(isPresented: Binding(
            get: { tryOutCoordinator.isShowingPembahasan && tryOutCoordinator.currentPembahasanTryOutId != nil },
            set: { newValue in tryOutCoordinator.isShowingPembahasan = newValue }
        )) {
            NavigationStack {
                PembahasanView(tryOutId: tryOutCoordinator.currentPembahasanTryOutId!)
                    .environmentObject(tryOutCoordinator)
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
        // Auto switch to home tab when returning from pembahasan
        .onChange(of: tryOutCoordinator.isShowingPembahasan) { _, isShowing in
            if !isShowing {
                print("🏠 Auto-switching to home tab from pembahasan")
                selectedIndex = 0
            }
        }
        // Listen for notification to switch to MyClass tab
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToMyClassTab"))) { _ in
            selectedIndex = 2
            // Also nudge MyClassView to refresh with retry in case of backend delay
            NotificationCenter.default.post(name: NSNotification.Name("RefreshMyClassesWithRetry"), object: nil)
        }
        // Ensure MyClass refreshes when user manually switches to the tab
        .onChange(of: selectedIndex) { _, newIndex in
            if newIndex == 2 {
                // Use retry to handle propagation delay after recent purchase
                NotificationCenter.default.post(name: NSNotification.Name("RefreshMyClassesWithRetry"), object: nil)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
        .environmentObject(TryOutCoordinator())
        .environmentObject(MyClassViewModel())
}
