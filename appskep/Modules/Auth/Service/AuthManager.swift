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
  @Published var authToken: String?
  
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
      saveAuthData(token: authData.token, user: authData.user)
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
      saveAuthData(token: authData.token, user: authData.user)
    }
    
    return response
  }
  
  func logout() {
    authToken = nil
    currentUser = nil
    isAuthenticated = false
    
    userDefaults.removeObject(forKey: tokenKey)
    userDefaults.removeObject(forKey: userKey)
  }
  
  private func saveAuthData(token: String, user: UserModel) {
    authToken = token
    currentUser = user
    isAuthenticated = true
    
    userDefaults.set(token, forKey: tokenKey)
    if let userData = try? JSONEncoder().encode(user) {
      userDefaults.set(userData, forKey: userKey)
    }
  }
  
  private func loadStoredAuth() {
    authToken = userDefaults.string(forKey: tokenKey)
    
    if let userData = userDefaults.data(forKey: userKey),
       let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
      currentUser = user
    }
    
    isAuthenticated = authToken != nil && currentUser != nil
  }
  
  func updateUserData(_ updatedUser: UserModel) {
    self.currentUser = updatedUser
    
    // Save to UserDefaults
    if let encoded = try? JSONEncoder().encode(updatedUser) {
      userDefaults.set(encoded, forKey: userKey)
    }
  }
}
