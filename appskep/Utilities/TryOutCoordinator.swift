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
    @Published var currentTryOutCode: String?
    
    // Result states
    @Published var isShowingResult = false
    @Published var tryOutResult: TryOutResultsData?
    
    // Pembahasan states
    @Published var isShowingPembahasan = false
    @Published var currentPembahasanTryOutCode: String?
    
    func startTryOut(tryoutCode: String) {
        print("🚀 TryOutCoordinator: Starting try out with code: \(tryoutCode)")
        currentTryOutCode = tryoutCode
        isShowingTryOut = true
    }
    
    func showResult(_ result: TryOutResultsData) {
        print("📊 TryOutCoordinator: Showing result for try out code: \(result.tryout_code)")
        tryOutResult = result
        isShowingTryOut = false
        isShowingResult = true
    }
    
    func backToHome() {
        print("🏠 TryOutCoordinator: Going back to home")
        isShowingResult = false
        isShowingTryOut = false
        tryOutResult = nil
        currentTryOutCode = nil
    }
    
    // Pembahasan methods
    func showPembahasan(tryoutCode: String) {
        print("📚 TryOutCoordinator: Showing pembahasan for try out code: \(tryoutCode)")
        currentPembahasanTryOutCode = tryoutCode
        isShowingPembahasan = true
    }
    
    func closePembahasan() {
        print("📚 TryOutCoordinator: Closing pembahasan")
        isShowingPembahasan = false
        currentPembahasanTryOutCode = nil
    }
    
    func transitionToPembahasan(tryoutCode: String) {
        print("📚 TryOutCoordinator: Transitioning from result to pembahasan for try out code: \(tryoutCode)")
        // Dismiss result first to avoid multiple sheets
        isShowingResult = false
        tryOutResult = nil
        
        // Present pembahasan after the result has been dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.currentPembahasanTryOutCode = tryoutCode
            self.isShowingPembahasan = true
        }
    }
}
