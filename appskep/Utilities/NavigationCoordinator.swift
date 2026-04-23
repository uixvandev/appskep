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
    @Published var tryOutResult: TryOutResultsData?
    
    private init() {}
    
    enum AppView {
        case mainTab
        case tryOut(tryoutCode: String)
        case result(TryOutResultsData)
    }
    
    func startTryOut(tryoutCode: String) {
        currentView = .tryOut(tryoutCode: tryoutCode)
    }
    
    func showResult(_ result: TryOutResultsData) {
        tryOutResult = result
        currentView = .result(result)
    }
    
    func navigateToHome() {
        currentView = .mainTab
        tryOutResult = nil
    }
}
