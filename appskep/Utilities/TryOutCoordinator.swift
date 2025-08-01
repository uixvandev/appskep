//
//  TryOutCoordinator.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation
import SwiftUI

class TryOutCoordinator: ObservableObject {
    @Published var isShowingTryOut = false
    @Published var isShowingResult = false
    @Published var currentTryOutId: Int?
    @Published var tryOutResult: TryOutResult?
    
    func startTryOut(tryOutId: Int) {
        print("🚀 TryOutCoordinator: Starting try out with ID: \(tryOutId)")
        currentTryOutId = tryOutId
        isShowingTryOut = true
    }
    
    func showResult(_ result: TryOutResult) {
        print("📊 TryOutCoordinator: Showing result with score: \(result.score)")
        print("📊 TryOutCoordinator: isShowingTryOut before: \(isShowingTryOut)")
        print("📊 TryOutCoordinator: isShowingResult before: \(isShowingResult)")
        
        tryOutResult = result
        isShowingResult = true
        isShowingTryOut = false // Close try out, show result
        
        print("📊 TryOutCoordinator: isShowingTryOut after: \(isShowingTryOut)")
        print("📊 TryOutCoordinator: isShowingResult after: \(isShowingResult)")
    }
    
    func backToHome() {
        print("🏠 TryOutCoordinator: Going back to home")
        print("🏠 TryOutCoordinator: isShowingTryOut before: \(isShowingTryOut)")
        print("🏠 TryOutCoordinator: isShowingResult before: \(isShowingResult)")
        
        isShowingResult = false
        isShowingTryOut = false
        currentTryOutId = nil
        tryOutResult = nil
        
        print("🏠 TryOutCoordinator: isShowingTryOut after: \(isShowingTryOut)")
        print("🏠 TryOutCoordinator: isShowingResult after: \(isShowingResult)")
    }
}
