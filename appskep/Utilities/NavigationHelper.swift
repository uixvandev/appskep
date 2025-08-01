//
//  NavigationHelper.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation
import SwiftUI
import UIKit

extension Notification.Name {
    static let navigateToHome = Notification.Name("navigateToHome")
}

class NavigationHelper {
    static let shared = NavigationHelper()
    
    private init() {}
    
    func navigateToHome() {
        print("📢 Posting navigate to home notification")
        
        // Post notification multiple times to ensure delivery
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                NotificationCenter.default.post(name: .navigateToHome, object: nil)
                print("📢 Posted notification attempt \(i + 1)")
            }
        }
        
        // Also try direct UIKit approach
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.forceNavigateToHome()
        }
    }
    
    private func forceNavigateToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("❌ Could not access window scene")
            return
        }
        
        // Find TabBarController and force navigation
        if let tabBarController = self.findTabBarController(from: window.rootViewController) {
            print("✅ Force navigating to home tab")
            tabBarController.selectedIndex = 0
            
            // Reset all navigation stacks
            tabBarController.viewControllers?.forEach { viewController in
                if let navController = viewController as? UINavigationController {
                    navController.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    private func findTabBarController(from viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBar = viewController as? UITabBarController {
            return tabBar
        }
        
        for child in viewController.children {
            if let result = findTabBarController(from: child) {
                return result
            }
        }
        
        if let presented = viewController.presentedViewController {
            if let result = findTabBarController(from: presented) {
                return result
            }
        }
        
        return nil
    }
}
