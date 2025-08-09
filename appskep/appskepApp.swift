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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if authManager.isAuthenticated {
                        MainTabView()
                    } else {
                        LoginView()
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(tryOutCoordinator)
            .preferredColorScheme(.light)
        }
    }
}
