//
//  AuthManager.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

@MainActor
class AuthManager: ObservableObject {
  static let shared = AuthManager()
  
  @Published var isAuthenticated = false
  @Published var currentUser: UserModel?
  @Published var authToken: String? // Keep this separate from UserModel
  
  private let userDefaults = UserDefaults.standard
  private let tokenKey = "auth_token"
  private let userKey = "current_user"
  
  private init() {
    loadStoredAuth()
  }
  
  func register(name: String, email: String, password: String) async throws -> AuthResponse {
    let request = RegisterRequest(name: name, email: email, password: password)
    let requestData = try JSONEncoder().encode(request)
    
    let response: AuthResponse = try await APIService.shared.performRequest(
      endpoint: .register,
      method: .POST,
      body: requestData,
      responseType: AuthResponse.self
    )
    
    if response.success, let authData = response.data {
      // Store token separately
      self.authToken = authData.token
      self.currentUser = authData.user
      self.isAuthenticated = true
      
      // Save to UserDefaults
      userDefaults.set(authData.token, forKey: tokenKey)
      if let userData = try? JSONEncoder().encode(authData.user) {
        userDefaults.set(userData, forKey: userKey)
      }
    }
    
    return response
  }
  
  func login(email: String, password: String) async throws -> AuthResponse {
    let request = LoginRequest(email: email, password: password)
    let requestData = try JSONEncoder().encode(request)
    
    let response: AuthResponse = try await APIService.shared.performRequest(
      endpoint: .login,
      method: .POST,
      body: requestData,
      responseType: AuthResponse.self
    )
    
    if response.success, let authData = response.data {
      // Store token separately
      self.authToken = authData.token
      self.currentUser = authData.user
      self.isAuthenticated = true
      
      // Save to UserDefaults
      userDefaults.set(authData.token, forKey: tokenKey)
      if let userData = try? JSONEncoder().encode(authData.user) {
        userDefaults.set(userData, forKey: userKey)
      }
    }
    
    return response
  }
  
  func logout() {
    authToken = nil
    currentUser = nil
    isAuthenticated = false
    
    // Clear UserDefaults
    userDefaults.removeObject(forKey: tokenKey)
    userDefaults.removeObject(forKey: userKey)
  }
  
  private func loadStoredAuth() {
    // Load token
    if let token = userDefaults.string(forKey: tokenKey) {
      self.authToken = token
    }
    
    // Load user
    if let userData = userDefaults.data(forKey: userKey),
       let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
      self.currentUser = user
    }
    
    // Set authentication state
    self.isAuthenticated = authToken != nil && currentUser != nil
  }
  
  // Method to update user profile
  func updateCurrentUser(_ user: UserModel) {
    self.currentUser = user
    
    // Save updated user to UserDefaults
    if let userData = try? JSONEncoder().encode(user) {
      userDefaults.set(userData, forKey: userKey)
    }
  }
}
