//
//  TryOutModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

// MARK: - Start TryOut
struct StartTryOutRequest: Codable {
  let order_id: Int
  let paket_id: Int
}

struct StartTryOutResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutSessionData?
  let error: String?
}

struct TryOutSessionData: Codable {
  let id: Int
  let order_id: Int
  let paket_id: Int
  let started_at: String
  let status: String
  let paket_name: String
}

// MARK: - TryOut Detail
struct TryOutDetailResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutDetail
}

struct TryOutDetail: Codable, Identifiable, Equatable {
  let id: Int
  let paket: Paket
  let soals: [Soal]
}

struct Soal: Codable, Identifiable, Equatable {
  let id: Int
  let question: String
  let explanation: String
  let pilihan_jawaban: [PilihanJawaban]
}

struct PilihanJawaban: Codable, Identifiable, Equatable {
  let id: Int
  let soal_id: Int
  let option_text: String
  let is_correct: Bool
}

// MARK: - Submit All Answers
struct SubmitAllAnswersRequest: Codable {
  let try_out_id: Int
  let answers: [AnswerSubmission]
}

struct AnswerSubmission: Codable {
  let soal_id: Int
  let pilihan_jawaban_id: Int
  let is_doubt: Bool
}

struct SubmitAllAnswersResponse: Codable {
  let success: Bool
  let message: String
  let error: String?
}

//MARK: - Finish TryOut
struct FinishTryOutRequest: Codable {
  let try_out_id: Int
}

struct FinishTryOutResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutResult?
  let error: String?
}

struct TryOutResult: Codable {
  let id: Int
  let order_id: Int
  let paket_id: Int
  let started_at: String
  let finished_at: String
  let score: Int
  let paket: Paket
  let soals: [Soal]
  let answers: [TryOutAnswer]
}

struct TryOutAnswer: Codable {
  let id: Int
  let try_out_id: Int
  let soal_id: Int
  let pilihan_jawaban_id: Int
  let is_doubt: Bool
  let soal: AnswerSoal
  let pilihan_jawaban: AnswerPilihanJawaban
}

struct AnswerSoal: Codable {
  let id: Int
  let question: String
  let explanation: String
}

struct AnswerPilihanJawaban: Codable {
  let id: Int
  let soal_id: Int
  let option_text: String
  let is_correct: Bool
}

// MARK: - Try Out Results API
struct TryOutResultsResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutResultsData
}

struct TryOutResultsData: Codable {
  let tryout_id: Int
  let user_id: Int
  let paket_name: String
  let total_questions: Int
  let answered_questions: Int
  let correct_answers: Int
  let wrong_answers: Int
  let unanswered: Int
  let score: Int
  let percentage: Int
  let grade: String
  let started_at: String
  let finished_at: String
  let duration_minutes: Int
  let passed: Bool
  let passing_score: Int
}

// MARK: - Pembahasan API
struct PembahasanResponse: Codable {
  let success: Bool
  let message: String
  let data: PembahasanData
}

struct PembahasanData: Codable {
  let tryout_id: Int
  let questions: [PembahasanQuestion]
  let summary: PembahasanSummary
}

struct PembahasanQuestion: Codable, Identifiable {
  let soal_id: Int
  let question: String
  let user_answer: UserAnswer
  let correct_answer: CorrectAnswer
  let all_options: [PembahasanOption]
  let explanation: String
  let is_user_correct: Bool
  let category: String
  
  var id: Int { soal_id }
}

struct UserAnswer: Codable {
  let pilihan_jawaban_id: Int
  let option_text: String
  let is_correct: Bool
}

struct CorrectAnswer: Codable {
  let pilihan_jawaban_id: Int
  let option_text: String
  let is_correct: Bool
}

struct PembahasanOption: Codable, Identifiable {
  let id: Int
  let option_text: String
  let is_correct: Bool
}

struct PembahasanSummary: Codable {
  let correct_by_category: [String: Int]
  let wrong_by_category: [String: Int]
}

struct TryOutHistoryResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutHistoryData
}

struct TryOutHistoryData: Codable {
  let data: [TryOutHistoryItem]
  let page: Int
  let limit: Int
  let total_items: Int
  let total_pages: Int
}

struct TryOutHistoryItem: Codable, Identifiable {
    let id: Int
    let order_id: Int
    let paket_id: Int
    let started_at: String
    let finished_at: String?
    let score: Int?
    let paket: Paket
    
    enum CodingKeys: String, CodingKey {
        case id, order_id, paket_id, started_at, finished_at, score, paket
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        order_id = try container.decode(Int.self, forKey: .order_id)
        paket_id = try container.decode(Int.self, forKey: .paket_id)
        started_at = try container.decode(String.self, forKey: .started_at)
        
        // Handle nullable finished_at
        finished_at = try container.decodeIfPresent(String.self, forKey: .finished_at)
        
        // Handle nullable score
        score = try container.decodeIfPresent(Int.self, forKey: .score)
        
        paket = try container.decode(Paket.self, forKey: .paket)
    }
}

// MARK: - Retry Eligibility Response (Updated to match actual API)
struct RetryEligibilityResponse: Codable {
  let success: Bool
  let message: String
  let data: RetryEligibilityData?
  let error: String?
}

struct RetryEligibilityData: Codable {
  // Fields that actually exist in API response
  let attempt_number: Int
  let total_attempts: Int
  let max_attempts: Int
  let can_retry: Bool
  let best_score: Int?
  let has_passed: Bool
  
  // Optional fields that may not be in API response
  let can_start_new: Bool?
  let is_unlimited: Bool?
  let last_attempt: LastAttemptInfo?
  let next_retry_at: String?
  
  enum CodingKeys: String, CodingKey {
    case attempt_number
    case total_attempts
    case max_attempts
    case can_retry
    case best_score
    case has_passed
    case can_start_new
    case is_unlimited
    case last_attempt
    case next_retry_at
  }
  
  // Custom decoder to handle missing fields gracefully
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // Required fields from API response
    attempt_number = try container.decode(Int.self, forKey: .attempt_number)
    total_attempts = try container.decode(Int.self, forKey: .total_attempts)
    max_attempts = try container.decode(Int.self, forKey: .max_attempts)
    can_retry = try container.decode(Bool.self, forKey: .can_retry)
    has_passed = try container.decode(Bool.self, forKey: .has_passed)
    
    // Handle best_score (can be 0 or null)
    best_score = try container.decodeIfPresent(Int.self, forKey: .best_score)
    
    // Optional fields with fallback logic
    can_start_new = try container.decodeIfPresent(Bool.self, forKey: .can_start_new)
    is_unlimited = try container.decodeIfPresent(Bool.self, forKey: .is_unlimited)
    last_attempt = try container.decodeIfPresent(LastAttemptInfo.self, forKey: .last_attempt)
    next_retry_at = try container.decodeIfPresent(String.self, forKey: .next_retry_at)
  }
  
  // Add encode method to satisfy Codable
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(attempt_number, forKey: .attempt_number)
    try container.encode(total_attempts, forKey: .total_attempts)
    try container.encode(max_attempts, forKey: .max_attempts)
    try container.encode(can_retry, forKey: .can_retry)
    try container.encode(has_passed, forKey: .has_passed)
    try container.encodeIfPresent(best_score, forKey: .best_score)
    try container.encodeIfPresent(can_start_new, forKey: .can_start_new)
    try container.encodeIfPresent(is_unlimited, forKey: .is_unlimited)
    try container.encodeIfPresent(last_attempt, forKey: .last_attempt)
    try container.encodeIfPresent(next_retry_at, forKey: .next_retry_at)
  }
  
  // Computed properties for UI logic based on actual API data
  var computedCanStartNew: Bool {
    // If can_start_new is not provided, determine from total_attempts
    return can_start_new ?? (total_attempts == 0)
  }
  
  var computedIsUnlimited: Bool {
    // If is_unlimited is not provided, check if max_attempts is 0
    return is_unlimited ?? (max_attempts == 0)
  }
  
  var hasReachedMaxAttempts: Bool {
    // Only true if we have limited attempts AND reached the limit
    return !computedIsUnlimited && max_attempts > 0 && total_attempts >= max_attempts
  }
  
  var canStartNewAttempt: Bool {
    // Can start if it's first time OR can retry
    return total_attempts == 0 || can_retry
  }
}

// MARK: - Supporting Types (Single definition only)
struct LastAttemptInfo: Codable, Identifiable {
  let id: Int
  let score: Int
  let passed: Bool
  let finished_at: String
  let status: String
}

// MARK: - Try Out Action State
enum TryOutActionState {
  case loading
  case canStart
  case showResult(LastAttemptInfo)
  case maxAttemptsReached(bestScore: Int)
  case waitingRetry(nextRetryDate: Date)
  case error(String)
  
  var lastAttempt: LastAttemptInfo? {
    if case .showResult(let attempt) = self {
      return attempt
    }
    return nil
  }
}
