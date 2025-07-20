//
//  SearchViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var ukomClasses: [UkomClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private var totalPages = 1
    
    func fetchUkomClasses() async {
        guard !isLoading, currentPage <= totalPages else { return }
        
        isLoading = true
        
        do {
            let response: UkomClassResponse = try await APIService.shared.performRequest(
                endpoint: .getAllKelas(page: currentPage, limit: 10),
                method: .GET,
                responseType: UkomClassResponse.self
            )
            
            if response.success {
                self.ukomClasses.append(contentsOf: response.data.data)
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
