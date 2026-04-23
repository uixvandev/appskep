//
//  OrderModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation
import SwiftUI

struct OrderRequest: Codable {
    let class_code: String
}

struct OrderResponse: Codable {
    let success: Bool
    let message: String
    let data: OrderData?
    let error: String?
}

struct OrderData: Codable {
    let snap_redirect_url: String
}

// MARK: - Order Response Models
struct OrderListResponse: Codable {
    let success: Bool
    let message: String
    let data: OrderListData
}

struct OrderListData: Codable {
    let data: [OrderItem]
    let page: Int
    let limit: Int
    let total_items: Int
    let total_pages: Int
}

struct OrderDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: OrderItem
}

struct CheckAccessResponse: Codable {
    let success: Bool
    let message: String
    let data: AccessData
}

struct AccessData: Codable {
    let has_access: Bool
    let expires_at: String?
}

// MARK: - Core Models
struct OrderItem: Codable, Identifiable {
    let order_number: String
    let class_code: String
    let email: String
    let status: OrderStatus
    let payment_reference: String
    let gross_amount: Int
    let snap_token: String?
    let snap_redirect_url: String?
    let created_at: String
    let updated_at: String
    let kelas: KelasInfo
    
    var id: String { order_number }
    
    enum CodingKeys: String, CodingKey {
        case order_number
        case class_code
        case email
        case status
        case payment_reference
        case gross_amount
        case snap_token
        case snap_redirect_url
        case created_at
        case updated_at
        case kelas
    }
    
    // Computed properties for UI
    var formattedAmount: String {
        return "Rp \(gross_amount.formatted(.number))"
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: created_at) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return created_at
    }
    
    var canPay: Bool {
        return status == .pending && snap_redirect_url != nil
    }
    
    var canAccessClass: Bool {
        return status == .success
    }
    
    var canRetry: Bool {
        return status == .failed
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case success = "success"
    case failed = "failed"
    case cancel = "cancel"
    
    var displayName: String {
        switch self {
        case .pending: return "Menunggu Pembayaran"
        case .success: return "Berhasil"
        case .failed: return "Gagal"
        case .cancel: return "Dibatalkan"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .success: return .green
        case .failed: return .red
        case .cancel: return .red
        }
    }
    
    var backgroundColor: Color {
        return color.opacity(0.1)
    }
}

struct KelasInfo: Codable {
    let class_code: String
    let name: String
    let description: String
    let price: Int
}

// MARK: - Filter & Search
enum OrderFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case success = "success"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .all: return "Semua"
        case .pending: return "Menunggu"
        case .success: return "Berhasil"
        case .failed: return "Gagal"
        }
    }
}
