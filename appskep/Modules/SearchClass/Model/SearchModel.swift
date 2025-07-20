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
    let id: Int
    let name: String
    let description: String
    let price: Int
}

struct UkomClassDetailResponse: Codable {
    let success: Bool
    let message: String
    let data: UkomClass
}
