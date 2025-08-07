//
//  NotificationViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

//
//  NotificationViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation
import UIKit

@MainActor
class NotificationViewModel: ObservableObject {
  @Published var notifications: [NotificationItem] = []
  @Published var isLoading = false
  @Published var isAutoRefreshing = false // Add this missing property
  @Published var errorMessage: String?
  @Published var unreadCount = 0
  
  // Pagination properties
  @Published var currentPage = 1
  @Published var totalPages = 1
  
  // Track last refresh time
  private var lastRefreshTime: Date?
  
  func fetchNotifications() async {
    guard currentPage <= totalPages, !isLoading else { return }
    
    isLoading = true
    errorMessage = nil
    
    do {
      let response: NotificationResponse = try await APIService.shared.performRequest(
        endpoint: .getNotifications(page: currentPage, limit: 20),
        method: .GET,
        responseType: NotificationResponse.self
      )
      
      if response.success {
        if currentPage == 1 {
          self.notifications = response.data.notifications
        } else {
          self.notifications.append(contentsOf: response.data.notifications)
        }
        self.totalPages = response.data.total_pages
        self.unreadCount = response.data.unread_count
        self.currentPage += 1
        self.lastRefreshTime = Date()
      } else {
        self.errorMessage = response.message
      }
    } catch {
      self.errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
  
  func refreshNotifications() async {
    currentPage = 1
    totalPages = 1
    notifications.removeAll()
    await fetchNotifications()
  }
  
  // Add this missing method
  func autoRefreshNotifications() async {
    // Don't auto refresh if user is actively loading
    guard !isLoading else { return }
    
    // Don't refresh too frequently (minimum 15 seconds between auto refreshes)
    if let lastRefresh = lastRefreshTime,
       Date().timeIntervalSince(lastRefresh) < 15 {
      return
    }
    
    isAutoRefreshing = true
    
    do {
      let response: NotificationResponse = try await APIService.shared.performRequest(
        endpoint: .getNotifications(page: 1, limit: 20),
        method: .GET,
        responseType: NotificationResponse.self
      )
      
      if response.success {
        // Only update if there are changes
        let newNotifications = response.data.notifications
        let newUnreadCount = response.data.unread_count
        
        // Check if there are new notifications
        let hasNewNotifications = !newNotifications.isEmpty &&
        (notifications.isEmpty || newNotifications.first?.id != notifications.first?.id)
        
        // Check if unread count changed
        let unreadCountChanged = newUnreadCount != unreadCount
        
        if hasNewNotifications || unreadCountChanged {
          // Reset pagination and update data
          self.currentPage = 2
          self.totalPages = response.data.total_pages
          self.notifications = newNotifications
          self.unreadCount = newUnreadCount
          self.lastRefreshTime = Date()
          
          // Show brief animation or haptic feedback for new notifications
          if hasNewNotifications {
            await MainActor.run {
              // Light haptic feedback for new notifications
              let impactFeedback = UIImpactFeedbackGenerator(style: .light)
              impactFeedback.impactOccurred()
            }
          }
        }
      }
    } catch {
      // Silent fail for auto refresh - don't show error to user
      print("Auto refresh failed: \(error)")
    }
    
    isAutoRefreshing = false
  }
  
  func fetchUnreadCount() async {
    do {
      let response: UnreadCountResponse = try await APIService.shared.performRequest(
        endpoint: .getUnreadCount,
        method: .GET,
        responseType: UnreadCountResponse.self
      )
      
      if response.success {
        self.unreadCount = response.data.unread_count
      }
    } catch {
      print("Failed to fetch unread count: \(error)")
    }
  }
  
  func markAsRead(_ notification: NotificationItem) async {
    guard !notification.is_read else { return }
    
    do {
      let response: MarkAsReadResponse = try await APIService.shared.performRequest(
        endpoint: .markNotificationAsRead(id: notification.id),
        method: .PUT,
        responseType: MarkAsReadResponse.self
      )
      
      if response.success {
        // Update local state
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
          // Create updated notification directly without intermediate variable
          notifications[index] = NotificationItem(
            id: notification.id,
            title: notification.title,
            description: notification.description,
            order_id: notification.order_id,
            is_read: true, // This is the only field that changes
            created_at: notification.created_at,
            updated_at: notification.updated_at,
            order_details: notification.order_details
          )
          
          // Decrease unread count
          if unreadCount > 0 {
            unreadCount -= 1
          }
        }
      }
    } catch {
      print("Failed to mark notification as read: \(error)")
    }
  }
  
  // Add this missing method
  func setAutoRefreshing(_ refreshing: Bool) {
    isAutoRefreshing = refreshing
  }
}
