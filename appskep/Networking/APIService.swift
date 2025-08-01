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
      print("❌ Invalid URL for endpoint: \(endpoint)")
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "ngrok-skip-browser-warning")
    
    // Log request details
    print("🌐 API Request: \(method.rawValue) \(url)")
    
    // Tambahkan header otentikasi jika endpoint memerlukannya
    if endpoint.requiresAuth {
      guard let token = await AuthManager.shared.authToken else {
        print("❌ No auth token available")
        throw APIError.unauthorized
      }
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      print("🔐 Authorization header added")
    }
    
    if let body = body {
      request.httpBody = body
      // Log request body
      if let jsonString = String(data: body, encoding: .utf8) {
        print("📤 Request Body: \(jsonString)")
      }
    }
    
    do {
      let (data, response) = try await session.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        print("❌ Invalid HTTP response")
        throw APIError.invalidResponse
      }
      
      // Log response details
      print("📥 HTTP Status Code: \(httpResponse.statusCode)")
      if let responseString = String(data: data, encoding: .utf8) {
        print("📥 Response Body: \(responseString)")
      }
      
      if (200...299).contains(httpResponse.statusCode) {
        do {
          let decodedResponse = try JSONDecoder().decode(T.self, from: data)
          print("✅ Successfully decoded response")
          return decodedResponse
        } catch {
          print("❌ Decoding error: \(error)")
          throw APIError.decodingError
        }
      } else {
        // Coba decode error response dari server
        do {
          let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
          print("❌ Server error: \(errorResponse.error ?? errorResponse.message)")
          throw APIError.serverError(errorResponse.error ?? errorResponse.message)
        } catch {
          print("❌ HTTP \(httpResponse.statusCode) - Failed to decode error response")
          throw APIError.serverError("HTTP \(httpResponse.statusCode)")
        }
      }
    } catch is DecodingError {
      print("❌ JSON decoding error")
      throw APIError.decodingError
    } catch let error as APIError {
      print("❌ API Error: \(error)")
      throw error
    } catch {
      print("❌ Network error: \(error.localizedDescription)")
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
  case unauthorized
  
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
