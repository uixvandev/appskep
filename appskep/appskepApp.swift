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
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
            .preferredColorScheme(.light)
        }
    }
}
