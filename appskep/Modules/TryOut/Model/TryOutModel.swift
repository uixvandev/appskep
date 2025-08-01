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
