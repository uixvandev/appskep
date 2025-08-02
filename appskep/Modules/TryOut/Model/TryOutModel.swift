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
    let finished_at: String
    let score: Int
    let paket: Paket
}
