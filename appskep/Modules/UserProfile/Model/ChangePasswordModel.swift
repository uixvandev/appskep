//
//  ChangePasswordModel.swift
//  appskep
//
//  Created by irfan wahendra on 07/08/25.
//

import Foundation

struct ChangePasswordRequest: Codable {
    let current_password: String
    let new_password: String
}

struct ChangePasswordResponse: Codable {
    let success: Bool
    let message: String
}
