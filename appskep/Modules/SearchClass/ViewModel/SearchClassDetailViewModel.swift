//
//  SearchClassDetailViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation
import SwiftUI

@MainActor
class SearchClassDetailViewModel: ObservableObject {
    @Published var ukomClass: UkomClass?
    @Published var pakets: [Paket] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showOrderAlert = false
    @Published var orderError: String?
    @Published var showWebView = false
    @Published var redirectURL: URL?
    
    // Add new properties for handling duplicate order
    @Published var showDuplicateOrderAlert = false
    @Published var duplicateOrderMessage: String?
    
    func fetchAllDetails(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        // Fetch both class details and pakets concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchClassDetail(id: id)
            }
            
            group.addTask {
                await self.fetchPakets(classId: id)
            }
        }
        
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
                print("✅ Fetched \(self.pakets.count) pakets for class \(classId)")
            } else {
                print("❌ Failed to fetch pakets: \(response.message)")
                self.pakets = []
            }
        } catch {
            print("❌ Error fetching pakets: \(error.localizedDescription)")
            self.pakets = []
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
        } catch APIError.conflict(let message, let errorCode) {
            // Handle the specific case when user already has access
            if errorCode == "order already paid" {
                self.duplicateOrderMessage = "Anda sudah memiliki akses ke kelas ini. Silakan cek di menu 'Kelas Saya' untuk mengakses materi."
                self.showDuplicateOrderAlert = true
            } else {
                self.duplicateOrderMessage = message
                self.showDuplicateOrderAlert = true
            }
        } catch {
            self.orderError = "Terjadi kesalahan: \(error.localizedDescription)"
            self.showOrderAlert = true
        }
    }
}
