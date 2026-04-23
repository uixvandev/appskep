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
import UserNotifications

@MainActor
class NotificationViewModel: ObservableObject {
  @Published var notifications: [NotificationItem] = []
  @Published var isLoading = false
  @Published var isAutoRefreshing = false // Add this missing property
  @Published var errorMessage: String?
  @Published var unreadCount = 0
  
  // Adaptive polling for unread count
  private var unreadTimer: Timer?
  private let pollingIntervals: [TimeInterval] = [15, 30, 60, 120, 300] // seconds
  private var pollingIndex: Int = 0
  private var lastUnreadValue: Int = 0
  
  // Pagination properties
  @Published var currentPage = 1
  @Published var totalPages = 1
  
  // Track last refresh time
  private var lastRefreshTime: Date?
  private let lastNotifiedPaymentIdKey = "lastNotifiedPaymentNotificationId"
  
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
        await handlePaymentNotificationsIfNeeded(from: response.data.notifications)
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
          await handlePaymentNotificationsIfNeeded(from: newNotifications)
          
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

  private func handlePaymentNotificationsIfNeeded(from items: [NotificationItem]) async {
    guard !items.isEmpty else { return }

    let lastNotifiedId = UserDefaults.standard.integer(forKey: lastNotifiedPaymentIdKey)
    let candidates = items
      .filter { $0.id > lastNotifiedId }
      .filter { $0.order_details.status.lowercased() == "success" }
      .filter { $0.title.localizedCaseInsensitiveContains("pembayaran") }

    guard !candidates.isEmpty else { return }

    let hasPermission = await requestNotificationAuthorizationIfNeeded()
    guard hasPermission else {
      print("❌ Notification permission not granted")
      return
    }

    let sortedCandidates = candidates.sorted { $0.id < $1.id }
    for item in sortedCandidates {
      let content = UNMutableNotificationContent()
      content.title = item.title
      content.body = item.description
      content.sound = .default

      let request = UNNotificationRequest(
        identifier: "payment-notification-\(item.id)",
        content: content,
        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      )

      do {
        try await UNUserNotificationCenter.current().add(request)
        print("✅ Scheduled payment notification from API id: \(item.id)")
      } catch {
        print("❌ Failed to schedule API notification: \(error.localizedDescription)")
      }
    }

    if let maxId = sortedCandidates.last?.id {
      UserDefaults.standard.set(maxId, forKey: lastNotifiedPaymentIdKey)
    }
  }

  private func requestNotificationAuthorizationIfNeeded() async -> Bool {
    let center = UNUserNotificationCenter.current()
    let settings = await withCheckedContinuation { continuation in
      center.getNotificationSettings { currentSettings in
        continuation.resume(returning: currentSettings)
      }
    }

    print("🔔 Notification status: \(settings.authorizationStatus.rawValue)")

    switch settings.authorizationStatus {
    case .authorized, .provisional, .ephemeral:
      return true
    case .notDetermined:
      return await withCheckedContinuation { continuation in
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          continuation.resume(returning: granted)
        }
      }
    case .denied:
      return false
    @unknown default:
      return false
    }
  }
  
  func fetchUnreadCount() async {
    do {
      let response: UnreadCountResponse = try await APIService.shared.performRequest(
        endpoint: .getUnreadCount,
        method: .GET,
        responseType: UnreadCountResponse.self
      )
      
      if response.success {
        let newValue = response.data.unread_count
        // Detect change to adjust polling speed
        if newValue != self.unreadCount {
          self.unreadCount = newValue
          self.lastUnreadValue = newValue
          // Speed up polling on change
          self.resetPollingSpeed()
        }
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
            notification_id: notification.notification_id,
            title: notification.title,
            description: notification.description,
            order_number: notification.order_number,
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

  // MARK: - Adaptive polling controls
  func startUnreadAutoRefresh() {
    stopUnreadAutoRefresh()
    lastUnreadValue = unreadCount
    scheduleNextUnreadTimer(interval: pollingIntervals[pollingIndex])
  }
  
  func stopUnreadAutoRefresh() {
    unreadTimer?.invalidate()
    unreadTimer = nil
  }
  
  private func scheduleNextUnreadTimer(interval: TimeInterval) {
    unreadTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self = self else { return }
        let before = self.unreadCount
        await self.fetchUnreadCount()
        let after = self.unreadCount
        // Backoff if no change, speed up if there is
        if after == before {
          if self.pollingIndex < self.pollingIntervals.count - 1 {
            self.pollingIndex += 1
          }
        } else {
          self.pollingIndex = 0
        }
        self.scheduleNextUnreadTimer(interval: self.pollingIntervals[self.pollingIndex])
      }
    }
    RunLoop.main.add(unreadTimer!, forMode: .common)
  }
  
  private func resetPollingSpeed() {
    pollingIndex = 0
    if unreadTimer != nil {
      // Reschedule with faster interval immediately
      stopUnreadAutoRefresh()
      scheduleNextUnreadTimer(interval: pollingIntervals[pollingIndex])
    }
  }
}
