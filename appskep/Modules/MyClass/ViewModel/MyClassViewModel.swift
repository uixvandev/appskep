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
  @Published var isRefreshing = false
  @Published var isLoadingMore = false
  @Published var errorMessage: String?
  
  private var currentPage = 1
  private var totalPages = 1
  
  var hasMorePages: Bool {
    currentPage <= totalPages
  }
  
  func fetchMyClasses() async {
    // Prevent multiple concurrent calls
    if isLoading || isLoadingMore {
      return
    }
    
    // Check if we have more pages for pagination
    if currentPage > totalPages && currentPage > 1 {
      return
    }
    
    if currentPage == 1 {
      isLoading = true
    } else {
      isLoadingMore = true
    }
    
    errorMessage = nil
    
    print("🔍 Fetching my classes - Page: \(currentPage)")
    
    do {
      let response: MyOrderResponse = try await APIService.shared.performRequest(
        endpoint: .getMyOrders(page: currentPage, limit: 10),
        method: .GET,
        responseType: MyOrderResponse.self
      )
      
      print("📥 API Response: success=\(response.success), total_items=\(response.data.total_items)")
      
      if response.success {
        let allOrders = response.data.data
        print("📋 Total orders received: \(allOrders.count)")
        
        // Filter for paid classes only
        let paidClasses = allOrders.filter { $0.status == "paid" }
        print("💳 Paid classes: \(paidClasses.count)")
        
        if currentPage == 1 {
          self.myPaidClasses = paidClasses
        } else {
          self.myPaidClasses.append(contentsOf: paidClasses)
        }
        
        self.totalPages = response.data.total_pages
        self.currentPage += 1
        
        print("✅ Updated classes count: \(self.myPaidClasses.count)")
        
        // Debug: Print each class
        for (index, order) in self.myPaidClasses.enumerated() {
          print("  \(index + 1). \(order.kelas.name) - Status: \(order.status)")
        }
        
      } else {
        let message = response.message
        print("❌ API Error: \(message)")
        self.errorMessage = message
      }
    } catch {
      let message = "Gagal memuat kelas: \(error.localizedDescription)"
      print("🚨 Network Error: \(message)")
      self.errorMessage = message
    }
    
    isLoading = false
    isLoadingMore = false
  }
  
  func refreshMyClasses() async {
    isRefreshing = true
    currentPage = 1
    // Don't clear classes immediately - keep them until new data arrives
    
    do {
      let response: MyOrderResponse = try await APIService.shared.performRequest(
        endpoint: .getMyOrders(page: 1, limit: 10),
        method: .GET,
        responseType: MyOrderResponse.self
      )
      
      print("🔄 Refresh API Response: success=\(response.success)")
      
      if response.success {
        let allOrders = response.data.data
        let paidClasses = allOrders.filter { $0.status == "paid" }
        
        // Only update after successful response
        self.myPaidClasses = paidClasses
        self.totalPages = response.data.total_pages
        self.currentPage = 2 // Next page to load
        self.errorMessage = nil
        
        print("🔄 Refreshed - Total classes: \(self.myPaidClasses.count)")
        
      } else {
        self.errorMessage = response.message
        print("❌ Refresh Error: \(response.message)")
      }
    } catch {
      self.errorMessage = "Gagal memuat kelas: \(error.localizedDescription)"
      print("🚨 Refresh Network Error: \(error)")
    }
    
    isRefreshing = false
  }
  
  func loadMoreClasses() async {
    guard hasMorePages && !isLoadingMore && !isRefreshing else {
      print("🛑 Load more blocked - hasMore: \(hasMorePages), isLoading: \(isLoadingMore), isRefreshing: \(isRefreshing)")
      return
    }
    
    await fetchMyClasses()
  }
  
  func clearError() {
    errorMessage = nil
  }
}
