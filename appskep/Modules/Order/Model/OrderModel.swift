//
//  OrderModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

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
