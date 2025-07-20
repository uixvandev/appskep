//
//  APIService.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

class APIService {
  static let shared = APIService()
  
  private let session = URLSession.shared
  
  private init() {}
  
  func performRequest<T: Codable>(
    endpoint: APIEndpoint,
    method: HTTPMethod,
    body: Data? = nil,
    responseType: T.Type
  ) async throws -> T {
    guard let url = endpoint.url else {
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Tambahkan header otentikasi jika endpoint memerlukannya
    if endpoint.requiresAuth {
      guard let token = await AuthManager.shared.authToken else {
        throw APIError.unauthorized
      }
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if let body = body {
      request.httpBody = body
    }
    
    do {
      let (data, response) = try await session.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
      }
      
      // Log untuk debugging
      print("Status Code: \(httpResponse.statusCode)")
      if let responseString = String(data: data, encoding: .utf8) {
        print("Response Body: \(responseString)")
      }
      
      if (200...299).contains(httpResponse.statusCode) {
        return try JSONDecoder().decode(T.self, from: data)
      } else {
        // Coba decode error response dari server
        // Anda mungkin perlu membuat model ErrorResponse yang lebih generik
        let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        throw APIError.serverError(errorResponse.error ?? errorResponse.message)
      }
    } catch is DecodingError {
      throw APIError.decodingError
    } catch let error as APIError {
      throw error
    } catch {
      throw APIError.networkError
    }
  }
}

enum HTTPMethod: String {
  case GET = "GET"
  case POST = "POST"
  case PUT = "PUT"
  case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case networkError
  case decodingError
  case serverError(String)
  case unauthorized // Tambahkan case ini
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid response from server"
    case .networkError:
      return "Network error occurred. Please check your connection."
    case .decodingError:
      return "Failed to process server response."
    case .serverError(let message):
      return message
    case .unauthorized:
      return "Authorization header required. Please log in."
    }
  }
}
