//
//  TransactionViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import Foundation
import SwiftUI

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var orders: [OrderItem] = []
    @Published var filteredOrders: [OrderItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var selectedOrder: OrderItem?
    @Published var showOrderDetail = false
    @Published var showPaymentWebView = false
    @Published var paymentURL: URL?
    
    // Filter & Search
    @Published var searchText = ""
    @Published var selectedFilter: OrderFilter = .all
    @Published var showFilterSheet = false
    
    // Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoadingMore = false
    
    // Computed Properties
    var hasMorePages: Bool {
        currentPage < totalPages
    }
    
    var filteredAndSearchedOrders: [OrderItem] {
        var result = orders
        
        // Apply filter
        if selectedFilter != .all {
            result = result.filter { $0.status.rawValue == selectedFilter.rawValue }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { order in
                order.kelas.name.localizedCaseInsensitiveContains(searchText) ||
                order.payment_reference.localizedCaseInsensitiveContains(searchText) ||
                String(order.order_number ?? 0).contains(searchText)
            }
        }
        
        return result.sorted { $0.created_at > $1.created_at }
    }
    
    // MARK: - API Methods
    func fetchOrders(refresh: Bool = false) async {
        // Prevent multiple concurrent calls
        if isLoading || isLoadingMore {
            return
        }
        
        // Setup for refresh or initial load
        if refresh {
            isRefreshing = true
            currentPage = 1
            // Don't clear orders yet - wait for successful response
        } else {
            // Check if we have more pages for pagination
            if currentPage > totalPages {
                return
            }
            
            if currentPage == 1 {
                isLoading = true
            } else {
                isLoadingMore = true
            }
        }
        
        errorMessage = nil
        
        do {
            let response: OrderListResponse = try await APIService.shared.performRequest(
                endpoint: .getOrderHistory(page: currentPage, limit: 10),
                method: .GET,
                responseType: OrderListResponse.self
            )
            
            if response.success {
                // Update data only after successful response
                if refresh || currentPage == 1 {
                    self.orders = response.data.data
                } else {
                    self.orders.append(contentsOf: response.data.data)
                }
                
                self.totalPages = response.data.total_pages
                self.currentPage += 1
                
                // Clear any previous error messages on success
                self.errorMessage = nil
                
            } else {
                self.errorMessage = response.message
                print("API Error: \(response.message)")
            }
        } catch {
            self.errorMessage = "Gagal memuat data transaksi: \(error.localizedDescription)"
            print("Network Error: \(error)")
        }
        
        // Always reset loading states
        isLoading = false
        isRefreshing = false
        isLoadingMore = false
    }
    
    func fetchOrderDetail(id: Int) async {
        do {
            let response: OrderDetailResponse = try await APIService.shared.performRequest(
                endpoint: .getOrderDetail(id: id),
                method: .GET,
                responseType: OrderDetailResponse.self
            )
            
            if response.success {
                self.selectedOrder = response.data
                // Update order in list if exists
                if let index = orders.firstIndex(where: { $0.id == id }) {
                    orders[index] = response.data
                }
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func checkClassAccess(kelasId: Int) async -> Bool {
        do {
            let response: CheckAccessResponse = try await APIService.shared.performRequest(
                endpoint: .checkClassAccess(kelasId: kelasId),
                method: .GET,
                responseType: CheckAccessResponse.self
            )
            
            return response.success && response.data.has_access
        } catch {
            print("Check access error: \(error)")
            return false
        }
    }
    
    // MARK: - UI Actions
    func showOrderDetailSheet(order: OrderItem) {
        selectedOrder = order
        showOrderDetail = true
    }
    
    func proceedToPayment(order: OrderItem) {
        // Keep track of the order being paid so we can poll status later
        selectedOrder = order
        
        guard let urlString = order.snap_redirect_url,
              let url = URL(string: urlString) else {
            errorMessage = "URL pembayaran tidak valid"
            return
        }
        
        paymentURL = url
        showPaymentWebView = true
    }
    
    func retryOrder(order: OrderItem) {
        // Navigate to class detail to create new order
        // This would typically be handled by coordinator/navigation
        print("Retry order: \(order.id)")
    }
    
    func refreshOrders() async {
        await fetchOrders(refresh: true)
    }
    
    func loadMoreOrders() async {
        guard hasMorePages && !isLoadingMore && !isRefreshing else { return }
        await fetchOrders()
    }
    
    func applyFilter(_ filter: OrderFilter) {
        selectedFilter = filter
        showFilterSheet = false
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Payment Callback Handler
    func handlePaymentCallback(success: Bool, orderID: String? = nil) async {
        if success {
            // If we know which order is being paid, poll until it becomes paid (handles webhook delay)
            if let payingOrderId = selectedOrder?.id {
                await waitUntilOrderPaid(orderId: payingOrderId, timeout: 20, interval: 2)
            }
            
            // Refresh orders to get updated status
            await refreshOrders()
            
            // Notify app to switch to MyClass tab and refresh classes
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMyClassTab"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("RefreshMyClasses"), object: nil, userInfo: [
                "orderID": orderID as Any
            ])
        }
        
        showPaymentWebView = false
        paymentURL = nil
    }
    
    // MARK: - Helpers
    private func waitUntilOrderPaid(orderId: Int, timeout: TimeInterval, interval: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            // Fetch order detail and check status
            await fetchOrderDetail(id: orderId)
            if selectedOrder?.status == .paid {
                print("✅ Order paid confirmed: \(orderId)")
                return
            }
            // Sleep for interval before next check
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        print("⌛️ Order not paid within timeout: \(orderId)")
    }
}
