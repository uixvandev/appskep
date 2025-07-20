//
//  MyClassViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

@MainActor
class MyClassViewModel: ObservableObject {
    @Published var myPaidClasses: [MyOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var totalPages = 1
    
    func fetchMyClasses() async {
        guard !isLoading, currentPage <= totalPages else { return }
        
        isLoading = true
        
        do {
            let response: MyOrderResponse = try await APIService.shared.performRequest(
                endpoint: .getMyOrders(page: currentPage, limit: 10),
                method: .GET,
                responseType: MyOrderResponse.self
            )
            
            if response.success {
                let paidClasses = response.data.data.filter { $0.status == "paid" }
                self.myPaidClasses.append(contentsOf: paidClasses)
                self.totalPages = response.data.total_pages
                self.currentPage += 1
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
