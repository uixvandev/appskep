//
//  TryOutCoordinator.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI
import Combine

@MainActor
class TryOutCoordinator: ObservableObject {
    // Try Out states
    @Published var isShowingTryOut = false
    @Published var currentTryOutId: Int?
    
    // Result states
    @Published var isShowingResult = false
    @Published var tryOutResult: TryOutResult?
    
    // Pembahasan states - Add these
    @Published var isShowingPembahasan = false
    @Published var currentPembahasanTryOutId: Int?
    
    func startTryOut(tryOutId: Int) {
        print("🚀 TryOutCoordinator: Starting try out with ID: \(tryOutId)")
        currentTryOutId = tryOutId
        isShowingTryOut = true
    }
    
    func showResult(_ result: TryOutResult) {
        print("📊 TryOutCoordinator: Showing result for try out ID: \(result.id)")
        tryOutResult = result
        isShowingTryOut = false
        isShowingResult = true
    }
    
    func backToHome() {
        print("🏠 TryOutCoordinator: Going back to home")
        isShowingResult = false
        isShowingTryOut = false
        tryOutResult = nil
        currentTryOutId = nil
    }
    
    // Add pembahasan methods
    func showPembahasan(tryOutId: Int) {
        print("📚 TryOutCoordinator: Showing pembahasan for try out ID: \(tryOutId)")
        currentPembahasanTryOutId = tryOutId
        isShowingPembahasan = true
    }
    
    func closePembahasan() {
        print("📚 TryOutCoordinator: Closing pembahasan")
        isShowingPembahasan = false
        currentPembahasanTryOutId = nil
    }
    
    func transitionToPembahasan(tryOutId: Int) {
        print("📚 TryOutCoordinator: Transitioning from result to pembahasan for try out ID: \(tryOutId)")
        // Dismiss result first to avoid multiple sheets
        isShowingResult = false
        tryOutResult = nil
        
        // Present pembahasan after the result has been dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.currentPembahasanTryOutId = tryOutId
            self.isShowingPembahasan = true
        }
    }
}
