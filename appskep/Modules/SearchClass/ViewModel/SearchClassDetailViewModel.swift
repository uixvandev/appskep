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
    
    func fetchAllDetails(classCode: String) async {
        isLoading = true
        errorMessage = nil
        
        // Fetch both class details and pakets concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchClassDetail(classCode: classCode)
            }
            
            group.addTask {
                await self.fetchPakets(classCode: classCode)
            }
        }
        
        isLoading = false
    }
    
    private func fetchClassDetail(classCode: String) async {
        do {
            let response: UkomClassDetailResponse = try await APIService.shared.performRequest(
                endpoint: .getKelasDetail(classCode: classCode),
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
    
    private func fetchPakets(classCode: String) async {
        do {
            let response: PaketResponse = try await APIService.shared.performRequest(
                endpoint: .getPaketsForKelas(classCode: classCode),
                method: .GET,
                responseType: PaketResponse.self
            )
            if response.success {
                self.pakets = response.data
                print("✅ Fetched \(self.pakets.count) pakets for class \(classCode)")
            } else {
                print("❌ Failed to fetch pakets: \(response.message)")
                self.pakets = []
            }
        } catch {
            print("❌ Error fetching pakets: \(error.localizedDescription)")
            self.pakets = []
        }
    }
    
    func buyClass(classCode: String) async {
        let orderRequest = OrderRequest(class_code: classCode)
        
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
