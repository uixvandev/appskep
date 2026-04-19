//
//  OrderModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation
import SwiftUI

struct OrderRequest: Codable {
    let kelas_id: Int
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
    let id: Int
    let order_number: Int?
    let kelas_id: Int
    let status: OrderStatus
    let payment_reference: String
    let gross_amount: Int
    let snap_token: String?
    let snap_redirect_url: String?
    let created_at: String
    let updated_at: String
    let user: UserInfo
    let kelas: KelasInfo
    
    enum CodingKeys: String, CodingKey {
        case id
        case order_number
        case kelas_id
        case status
        case payment_reference
        case gross_amount
        case snap_token
        case snap_redirect_url
        case created_at
        case updated_at
        case user
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
        return status == .paid
    }
    
    var canRetry: Bool {
        return status == .expired || status == .failure
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case paid = "paid"
    case expired = "expired"
    case cancel = "cancel"
    case failure = "failed"
    
    var displayName: String {
        switch self {
        case .pending: return "Menunggu Pembayaran"
        case .paid: return "Berhasil"
        case .expired: return "Kadaluarsa"
        case .cancel: return "Dibatalkan"
        case .failure: return "Gagal"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .paid: return .green
        case .expired: return .gray
        case .cancel: return .red
        case .failure: return .red
        }
    }
    
    var backgroundColor: Color {
        return color.opacity(0.1)
    }
}

struct UserInfo: Codable {
    let id: Int
    let name: String
    let email: String
}

struct KelasInfo: Codable {
    let id: Int
    let name: String
    let description: String
    let price: Int
}

// MARK: - Filter & Search
enum OrderFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case paid = "paid"
    case expired = "expired"
    case failure = "failed"
    
    var displayName: String {
        switch self {
        case .all: return "Semua"
        case .pending: return "Menunggu"
        case .paid: return "Berhasil"
        case .expired: return "Kadaluarsa"
        case .failure: return "Gagal"
        }
    }
}
