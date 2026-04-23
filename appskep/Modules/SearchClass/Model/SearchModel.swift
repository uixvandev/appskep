//
//  SearchModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

struct UkomClassResponse: Codable {
    let success: Bool
    let message: String
    let data: UkomClassData
}

struct UkomClassData: Codable {
    let data: [UkomClass]
    let page: Int
    let limit: Int
    let total_items: Int
    let total_pages: Int
}

struct UkomClass: Codable, Identifiable, Hashable {
    let class_code: String
    let name: String
    let description: String
    let price: Int
    let is_active: Int?
    
    var id: String { class_code }
    
    enum CodingKeys: String, CodingKey {
        case class_code, name, description, price, is_active
    }
}

struct UkomClassDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: UkomClass
}
