//
//  ChabotModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation

// MARK: - Chat Request
struct ChatRequest: Codable {
    let message: String
    let question_code: String?
}

// MARK: - Chat Response
struct ChatResponse: Codable {
    let success: Bool
    let message: String
    let data: ChatData
}

struct ChatData: Codable {
    let id: Int
    let message: String
    let response: String
    let question_code: String
    let soal_context: SoalContext?
    let created_at: String
}

// MARK: - Chat Delete Response
struct ChatDeleteResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Chat History Response
struct ChatHistoryResponse: Codable {
    let success: Bool
    let message: String
    let data: ChatHistoryData
}

struct ChatHistoryData: Codable {
    let messages: [ChatHistoryMessage]
    let page: Int
    let limit: Int
    let total_items: Int
    let total_pages: Int
}

struct ChatHistoryMessage: Codable, Identifiable {
    let id: Int
    let message: String
    let response: String
    let question_code: String
    let soal_context: SoalContext?
    let created_at: String
}

struct SoalContext: Codable {
    let question_code: String
    let question: String
    let explanation: String
    let options: [ChatOption]
}

struct ChatOption: Codable, Identifiable {
    let options_id: Int
    var id: Int { options_id }
    let option_text: String
    let is_correct: Bool
}
