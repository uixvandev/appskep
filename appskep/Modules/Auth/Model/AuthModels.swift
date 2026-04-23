//
//  AuthModels.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

struct RegisterRequest: Codable {
  let name: String
  let email: String
  let password: String
  let role: String
  
  init(name: String, email: String, password: String) {
    self.name = name
    self.email = email
    self.password = password
    self.role = "student" // Changed from "mahasiswa" to "student"
  }
}

struct LoginRequest: Codable {
  let email: String
  let password: String
}

// Response Models
struct AuthResponse: Codable {
  let success: Bool
  let message: String
  let data: AuthData?
  let error: String?
}

struct AuthData: Codable {
  let token: String
  let user: UserModel
}
