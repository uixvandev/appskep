//
//  TryOutModel.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import Foundation

// MARK: - Start TryOut
struct StartTryOutRequest: Codable {
  let order_number: String
  let package_code: String
}

struct StartTryOutResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutSessionData?
  let error: String?
}

struct TryOutSessionData: Codable {
  let tryout_code: String
  let order_number: String
  let package_code: String
  let started_at: String
  let status: String
  let paket_name: String

  enum CodingKeys: String, CodingKey {
    case tryout_code, order_number, package_code, started_at, status, paket_name
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    tryout_code = try container.decode(String.self, forKey: .tryout_code)
    order_number = try container.decode(String.self, forKey: .order_number)
    started_at = try container.decode(String.self, forKey: .started_at)
    status = try container.decode(String.self, forKey: .status)
    paket_name = try container.decode(String.self, forKey: .paket_name)

    if let packageCode = try container.decodeIfPresent(String.self, forKey: .package_code) {
      package_code = packageCode
    } else {
      throw DecodingError.keyNotFound(
        CodingKeys.package_code,
        DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing package_code")
      )
    }
  }

  init(tryout_code: String, order_number: String, package_code: String, started_at: String, status: String, paket_name: String) {
    self.tryout_code = tryout_code
    self.order_number = order_number
    self.package_code = package_code
    self.started_at = started_at
    self.status = status
    self.paket_name = paket_name
  }
}

// MARK: - TryOut Detail
struct TryOutDetailResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutDetail
}

struct TryOutDetail: Codable, Identifiable, Equatable {
  let tryout_code: String
  let package_code: String?
  let paket: Paket
  let soals: [Soal]
  
  var id: String { tryout_code }
}

struct Soal: Codable, Identifiable, Equatable {
  let question_code: String
  let question: String
  let explanation: String
  let pilihan_jawaban: [PilihanJawaban]
  
  var id: String { question_code }
}

struct PilihanJawaban: Codable, Identifiable, Equatable {
  let options_id: Int
  let question_code: String
  let option_text: String
  let is_correct: Bool
  
  var id: Int { options_id }
}

// MARK: - Submit All Answers
struct SubmitAllAnswersRequest: Codable {
  let tryout_code: String
  let answers: [AnswerSubmission]
}

struct AnswerSubmission: Codable {
  let question_code: String
  let options_id: Int
  let is_doubt: Bool
}

struct SubmitAllAnswersResponse: Codable {
  let success: Bool
  let message: String
  let error: String?
}

//MARK: - Finish TryOut
struct FinishTryOutRequest: Codable {
  let tryout_code: String
}

struct FinishTryOutResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutResultsData?
  let error: String?
}

// MARK: - Try Out Results API (used by both finish and results endpoints)
struct TryOutResultsResponse: Codable {
  let success: Bool
  let message: String
  let data: TryOutResultsData
}

struct TryOutResultsData: Codable {
  let tryout_code: String
  let paket_name: String
  let total_questions: Int
  let answered_questions: Int
  let correct_answers: Int
  let wrong_answers: Int
  let unanswered: Int
  let score: Double
  let percentage: Double
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
  let tryout_code: String
  let questions: [PembahasanQuestion]
  let summary: PembahasanSummary
}

struct PembahasanQuestion: Codable, Identifiable {
  let question_code: String
  let question: String
  let user_answer: UserAnswer?
  let correct_answer: CorrectAnswer
  let all_options: [PembahasanOption]
  let explanation: String
  let is_user_correct: Bool
  let category: String
  
  var id: String { question_code }
}

struct UserAnswer: Codable {
  let options_id: Int
  let option_text: String
  let is_correct: Bool
}

struct CorrectAnswer: Codable {
  let options_id: Int
  let option_text: String
  let is_correct: Bool
}

struct PembahasanOption: Codable, Identifiable {
  let options_id: Int
  let option_text: String
  let is_correct: Bool
  
  var id: Int { options_id }
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
    let tryout_code: String
    let order_number: String
    let package_code: String?
    let started_at: String
    let finished_at: String?
    let score: Double?
    let paket: Paket
    
    var id: String { tryout_code }
    
    enum CodingKeys: String, CodingKey {
      case tryout_code, order_number, package_code, started_at, finished_at, score, paket
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        tryout_code = try container.decode(String.self, forKey: .tryout_code)
        order_number = try container.decode(String.self, forKey: .order_number)
        package_code = try container.decodeIfPresent(String.self, forKey: .package_code)
        started_at = try container.decode(String.self, forKey: .started_at)
        
        // Handle nullable finished_at
        finished_at = try container.decodeIfPresent(String.self, forKey: .finished_at)
        
        // Handle nullable score
        score = try container.decodeIfPresent(Double.self, forKey: .score)
        
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
  let best_score: Double?
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
    best_score = try container.decodeIfPresent(Double.self, forKey: .best_score)
    
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
  let tryout_code: String
  let score: Double
  let passed: Bool
  let finished_at: String
  let status: String
  
  var id: String { tryout_code }
}

// MARK: - Try Out Action State
enum TryOutActionState {
  case loading
  case canStart
  case showResult(LastAttemptInfo)
  case maxAttemptsReached(bestScore: Double)
  case waitingRetry(nextRetryDate: Date)
  case error(String)
  
  var lastAttempt: LastAttemptInfo? {
    if case .showResult(let attempt) = self {
      return attempt
    }
    return nil
  }
}
