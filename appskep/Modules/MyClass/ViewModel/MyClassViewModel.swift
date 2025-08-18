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
  
  func resetPagination() {
    currentPage = 1
    totalPages = 1
  }
  
  func fetchMyClasses() async {
    // Prevent multiple concurrent calls
    if isLoading || isLoadingMore || isRefreshing { return }
    
    // Check if we have more pages for pagination
    if currentPage > totalPages && currentPage > 1 { return }
    
    if currentPage == 1 {
      isLoading = true
    } else {
      isLoadingMore = true
    }
    
    errorMessage = nil
    
    do {
      let response: MyOrderResponse = try await APIService.shared.performRequest(
        endpoint: .getMyOrders(page: currentPage, limit: 10),
        method: .GET,
        responseType: MyOrderResponse.self
      )
      
      if response.success {
        // Keep only paid classes; exclude pending/expired/cancel/failure
        let classes = response.data.data.filter { $0.status.lowercased() == "paid" }
        if currentPage == 1 {
          self.myPaidClasses = classes
        } else {
          self.myPaidClasses.append(contentsOf: classes)
        }
        self.totalPages = response.data.total_pages
        self.currentPage += 1
      } else {
        self.errorMessage = response.message
      }
    } catch let apiError as APIError {
      if case .cancelled = apiError {
        // Ignore silently
      } else {
        self.errorMessage = apiError.errorDescription
      }
    } catch {
      self.errorMessage = "Gagal memuat kelas: \(error.localizedDescription)"
    }
    
    isLoading = false
    isLoadingMore = false
  }
  
  func refreshMyClasses() async {
    // Prevent concurrent refresh/load calls
    if isRefreshing || isLoading || isLoadingMore { return }
    
    isRefreshing = true
    currentPage = 1
    
    do {
      let response: MyOrderResponse = try await APIService.shared.performRequest(
        endpoint: .getMyOrders(page: 1, limit: 10),
        method: .GET,
        responseType: MyOrderResponse.self
      )
      
      if response.success {
        // Keep only paid classes
        let classes = response.data.data.filter { $0.status.lowercased() == "paid" }
        self.myPaidClasses = classes
        self.totalPages = response.data.total_pages
        self.currentPage = min(2, self.totalPages + 1)
        self.errorMessage = nil
      } else {
        self.errorMessage = response.message
      }
    } catch let apiError as APIError {
      if case .cancelled = apiError {
        // Ignore silently
      } else {
        self.errorMessage = apiError.errorDescription
      }
    } catch {
      self.errorMessage = "Gagal memuat kelas: \(error.localizedDescription)"
    }
    
    isRefreshing = false
  }
  
  // Retry helper to handle backend propagation delays after payment
  func refreshWithRetry(retries: Int = 5, delaySeconds: Double = 2.0) async {
    await refreshMyClasses()
    if !myPaidClasses.isEmpty { return }
    
    var attempts = 1
    while attempts <= retries && myPaidClasses.isEmpty {
      try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
      await refreshMyClasses()
      attempts += 1
    }
  }
  
  func loadMoreClasses() async {
    guard hasMorePages && !isLoadingMore && !isRefreshing else { return }
    await fetchMyClasses()
  }
  
  func clearError() {
    errorMessage = nil
  }
}
