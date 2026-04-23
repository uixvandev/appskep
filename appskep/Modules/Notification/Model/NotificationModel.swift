//
//  NotificationModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation

// MARK: - Notification List Response
struct NotificationResponse: Codable {
    let success: Bool
    let message: String
    let data: NotificationData
}

struct NotificationData: Codable {
    let notifications: [NotificationItem]
    let page: Int
    let limit: Int
    let total_items: Int
    let total_pages: Int
    let unread_count: Int
}

struct NotificationItem: Codable, Identifiable {
    let notification_id: Int
    let title: String
    let description: String
    let order_number: String
    let is_read: Bool
    let created_at: String
    let updated_at: String
    let order_details: OrderDetails
    
    var id: Int { notification_id }
}

struct OrderDetails: Codable {
    let order_number: String
    let kelas_name: String
    let status: String
    let gross_amount: Int
}

// MARK: - Unread Count Response
struct UnreadCountResponse: Codable {
    let success: Bool
    let message: String
    let data: UnreadCountData
}

struct UnreadCountData: Codable {
    let unread_count: Int
}

// MARK: - Mark as Read Response
struct MarkAsReadResponse: Codable {
    let success: Bool
    let message: String
}
