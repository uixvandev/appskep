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
    
    // Add authorization header if endpoint requires it
    if endpoint.requiresAuth {
      // Use await for accessing @MainActor property from non-MainActor context
      if let token = await AuthManager.shared.authToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🔐 Authorization header added")
      } else {
        print("❌ No auth token available")
        throw APIError.unauthorized
      }
    }
    
    if let body = body {
      request.httpBody = body
      let bodyString = String(data: body, encoding: .utf8) ?? "Unable to convert body to string"
      print("📤 Request Body: \(bodyString)")
    }
    
    do {
      let (data, response) = try await session.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        print("❌ Invalid HTTP response")
        throw APIError.invalidResponse
      }
      
      let responseString = String(data: data, encoding: .utf8) ?? "Unable to convert response to string"
      print("📥 HTTP Status Code: \(httpResponse.statusCode)")
      print("📥 Response Body: \(responseString)")
      
      if 200...299 ~= httpResponse.statusCode {
        do {
          let decodedResponse = try JSONDecoder().decode(T.self, from: data)
          print("✅ Successfully decoded response")
          return decodedResponse
        } catch {
          print("❌ Decoding error: \(error)")
          throw APIError.decodingError
        }
      } else {
        // Handle specific error status codes
        switch httpResponse.statusCode {
        case 401:
          throw APIError.unauthorized
          
        case 409:
          // Handle conflict errors (like duplicate orders)
          do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            print("❌ Conflict error: \(errorResponse.message)")
            throw APIError.conflict(errorResponse.message, errorResponse.error)
          } catch is DecodingError {
            // If we can't decode the error response, fall back to generic message
            throw APIError.conflict("Konflik data", "conflict")
          }
          
        case 422:
          // Handle validation errors
          do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            print("❌ Validation error: \(errorResponse.message)")
            throw APIError.validationError(errorResponse.message)
          } catch is DecodingError {
            throw APIError.validationError("Data tidak valid")
          }
          
        default:
          // Try to decode generic error response
          do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            print("❌ Server error: \(errorResponse.message)")
            throw APIError.serverError(errorResponse.message)
          } catch is DecodingError {
            // Fallback for when we can't decode error response
            print("❌ HTTP \(httpResponse.statusCode) - Failed to decode error response")
            throw APIError.serverError("Terjadi kesalahan pada server (HTTP \(httpResponse.statusCode))")
          }
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

// MARK: - Error Response Model
struct ErrorResponse: Codable {
  let success: Bool
  let message: String
  let error: String?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? false
    message = try container.decode(String.self, forKey: .message)
    error = try container.decodeIfPresent(String.self, forKey: .error)
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
  case conflict(String, String?) // message, error code
  case validationError(String)
  
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
    case .conflict(let message, _):
      return message
    case .validationError(let message):
      return message
    }
  }
  
  // Helper property to get the error code for conflict errors
  var conflictErrorCode: String? {
    if case .conflict(_, let errorCode) = self {
      return errorCode
    }
    return nil
  }
}
