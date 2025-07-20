//
//  SearchClassDetailViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

@MainActor
class SearchClassDetailViewModel: ObservableObject {
    @Published var ukomClass: UkomClass?
    @Published var pakets: [Paket] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For Ordering
    @Published var orderError: String?
    @Published var showOrderAlert = false
    @Published var redirectURL: URL?
    @Published var showWebView = false

    func fetchAllDetails(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        await fetchClassDetail(id: id)
        await fetchPakets(classId: id)
        
        isLoading = false
    }

    private func fetchClassDetail(id: Int) async {
        do {
            let response: UkomClassDetailResponse = try await APIService.shared.performRequest(
                endpoint: .getKelasDetail(id: id),
                method: .GET,
                responseType: UkomClassDetailResponse.self
            )
            if response.success {
                self.ukomClass = response.data
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func fetchPakets(classId: Int) async {
        do {
            let response: PaketResponse = try await APIService.shared.performRequest(
                endpoint: .getPaketsForKelas(classId: classId),
                method: .GET,
                responseType: PaketResponse.self
            )
            if response.success {
                self.pakets = response.data
            }
        } catch {
            // Silently fail or handle error as needed
            print("Failed to fetch pakets: \(error.localizedDescription)")
        }
    }
    
    func buyClass(classId: Int) async {
        let orderRequest = OrderRequest(kelas_id: classId)
        
        do {
          let bodyData = try JSONEncoder().encode(orderRequest)
          
            let response: OrderResponse = try await APIService.shared.performRequest(
                endpoint: .createOrder,
                method: .POST,
                body: bodyData,
                responseType: OrderResponse.self
            )
            
            if response.success, let urlString = response.data?.snap_redirect_url, let url = URL(string: urlString) {
                self.redirectURL = url
                self.showWebView = true
            } else {
                self.orderError = response.message
                self.showOrderAlert = true
            }
        } catch {
            self.orderError = error.localizedDescription
            self.showOrderAlert = true
        }
    }
}
