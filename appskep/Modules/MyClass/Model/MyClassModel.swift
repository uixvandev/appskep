//
//  MyClassModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

struct MyOrderResponse: Codable {
    let success: Bool
    let message: String
    let data: MyOrderData
}

struct MyOrderData: Codable {
    let data: [MyOrder]
    let page: Int
    let limit: Int
    let total_items: Int
    let total_pages: Int
}

struct MyOrder: Codable, Identifiable {
    let id: Int
    let status: String
    let kelas: UkomClass
}
