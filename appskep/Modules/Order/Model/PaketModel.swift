//
//  PaketModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

struct Paket: Codable, Identifiable, Equatable {
    let id: Int
    let kelas_paket_id: Int?
    let kode_paket: String?
    let name: String
    let description: String
    let duration: Int
    let totalQuestions: Int? // Make this optional since API doesn't always provide it
    
    enum CodingKeys: String, CodingKey {
        case id
        case kelas_paket_id
        case kode_paket
        case name
        case description
        case duration
        case totalQuestions = "total_questions"
    }
    
    // Add custom initializer to handle missing totalQuestions
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        kelas_paket_id = try container.decodeIfPresent(Int.self, forKey: .kelas_paket_id)
        kode_paket = try container.decodeIfPresent(String.self, forKey: .kode_paket)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        totalQuestions = try container.decodeIfPresent(Int.self, forKey: .totalQuestions)
    }
    
    // Add convenience initializer for creating instances manually
    init(id: Int, kelas_paket_id: Int? = nil, kode_paket: String? = nil, name: String, description: String, duration: Int, totalQuestions: Int? = nil) {
        self.id = id
        self.kelas_paket_id = kelas_paket_id
        self.kode_paket = kode_paket
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

        if let successValue = try container.decodeIfPresent(Bool.self, forKey: .success) {
            success = successValue
            message = (try container.decodeIfPresent(String.self, forKey: .message)) ?? ""
        } else if let meta = try container.decodeIfPresent(PaketResponseMeta.self, forKey: .meta) {
            success = meta.status >= 200 && meta.status < 300
            message = meta.message
        } else {
            success = false
            message = ""
        }
        
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
        case success, message, data, meta
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(message, forKey: .message)
        try container.encode(data, forKey: .data)
    }
}

struct PaketResponseMeta: Codable {
    let status: Int
    let message: String
}

// For single paket response (like from /api/v1/pakets/{id})
struct SinglePaketResponse: Codable {
    let success: Bool
    let message: String
    let data: Paket?
}
