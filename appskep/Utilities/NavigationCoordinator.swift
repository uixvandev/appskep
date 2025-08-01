//
//  NavigationCoordinator.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation
import SwiftUI

class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()
    
    @Published var currentView: AppView = .mainTab
    @Published var tryOutResult: TryOutResult?
    
    private init() {}
    
    enum AppView {
        case mainTab
        case tryOut(tryOutId: Int)
        case result(TryOutResult)
    }
    
    func startTryOut(tryOutId: Int) {
        currentView = .tryOut(tryOutId: tryOutId)
    }
    
    func showResult(_ result: TryOutResult) {
        tryOutResult = result
        currentView = .result(result)
    }
    
    func navigateToHome() {
        currentView = .mainTab
        tryOutResult = nil
    }
}
