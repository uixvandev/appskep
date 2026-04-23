//
//  PaketModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

struct Paket: Codable, Identifiable, Equatable {
    let package_code: String
    let class_package_id: Int?
    let name: String
    let description: String
    let duration: Int
    let totalQuestions: Int? // Make this optional since API doesn't always provide it
    let is_active: Int?
    
    var id: String { package_code }
    
    enum CodingKeys: String, CodingKey {
        case package_code
        case class_package_id
        case name
        case description
        case duration
        case totalQuestions = "total_questions"
        case is_active
    }
    
    // Add custom initializer to handle missing totalQuestions
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        package_code = try container.decode(String.self, forKey: .package_code)
        class_package_id = try container.decodeIfPresent(Int.self, forKey: .class_package_id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        totalQuestions = try container.decodeIfPresent(Int.self, forKey: .totalQuestions)
        is_active = try container.decodeIfPresent(Int.self, forKey: .is_active)
    }
    
    // Add convenience initializer for creating instances manually
    init(package_code: String, class_package_id: Int? = nil, name: String, description: String, duration: Int, totalQuestions: Int? = nil, is_active: Int? = nil) {
        self.package_code = package_code
        self.class_package_id = class_package_id
        self.name = name
        self.description = description
        self.duration = duration
        self.totalQuestions = totalQuestions
        self.is_active = is_active
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

// For single paket response (like from /api/v1/pakets/{package_code})
struct SinglePaketResponse: Codable {
    let success: Bool
    let message: String
    let data: Paket?
}
