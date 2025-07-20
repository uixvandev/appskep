//
//  PaketModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

struct Paket: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let duration: Int
}

struct PaketResponse: Codable {
    let success: Bool
    let message: String
    let data: [Paket]
}
