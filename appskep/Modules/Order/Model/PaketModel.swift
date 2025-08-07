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
    let totalQuestions: Int? // Make this optional since API doesn't always provide it
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case duration
        case totalQuestions = "total_questions"
    }
    
    // Add custom initializer to handle missing totalQuestions
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        totalQuestions = try container.decodeIfPresent(Int.self, forKey: .totalQuestions)
    }
    
    // Add convenience initializer for creating instances manually
    init(id: Int, name: String, description: String, duration: Int, totalQuestions: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.totalQuestions = totalQuestions
    }
}

// Update PaketResponse to handle null data - SIMPLIFIED VERSION
struct PaketResponse: Codable {
    let success: Bool
    let message: String
    let data: [Paket]
    
    // Custom decoder to handle null data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decode(String.self, forKey: .message)
        
        // Try to decode data array, if fails or null, use empty array
        do {
            if try container.decodeNil(forKey: .data) {
                // Data is explicitly null
                data = []
            } else {
                // Try to decode as array
                data = try container.decode([Paket].self, forKey: .data)
            }
        } catch {
            // If decoding fails for any reason, default to empty array
            data = []
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case success, message, data
    }
}

// For single paket response (like from /api/v1/pakets/{id})
struct SinglePaketResponse: Codable {
    let success: Bool
    let message: String
    let data: Paket?
}
