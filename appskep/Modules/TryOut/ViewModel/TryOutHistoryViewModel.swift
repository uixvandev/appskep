//
//  TryOutHistoryViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation

@MainActor
class TryOutHistoryViewModel: ObservableObject {
    @Published var historyItems: [TryOutHistoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Pagination properties
    @Published var currentPage = 1
    @Published var totalPages = 1
    
    func fetchHistory() async {
        // Prevent fetching beyond the last page or if already loading
        guard currentPage <= totalPages, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: TryOutHistoryResponse = try await APIService.shared.performRequest(
                endpoint: .getTryOutHistory(page: currentPage, limit: 10),
                method: .GET,
                responseType: TryOutHistoryResponse.self
            )
            
            if response.success {
                self.historyItems.append(contentsOf: response.data.data)
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
    
    func refreshHistory() async {
        currentPage = 1
        totalPages = 1
        historyItems.removeAll()
        await fetchHistory()
    }
}
