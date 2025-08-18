//
//  appskepApp.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

@main
struct appskepApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var tryOutCoordinator = TryOutCoordinator()
    @StateObject private var myClassViewModel = MyClassViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    NavigationStack {
                        LoginView()
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(tryOutCoordinator)
            .environmentObject(myClassViewModel)
            .preferredColorScheme(.light)
        }
    }
}
