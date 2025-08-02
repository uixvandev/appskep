//
//  APIEndpoint.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

enum APIEndpoint {
  case register
  case login
  case getAllKelas(page: Int, limit: Int)
  case getKelasDetail(id: Int)
  case getPaketsForKelas(classId: Int)
  case createOrder
  case getMyOrders(page: Int, limit: Int)
  case startTryOut
  case getTryOutDetail(id: Int)
  case submitAllAnswers
  case finishTryOut
  case getTryOutResult(id: Int)
  case getPembahasan(id: Int)
  case sendChatMessage
  case getChatHistory(page: Int, limit: Int, soalId: Int)
  
  var requiresAuth: Bool {
    switch self {
    case .createOrder, .getMyOrders, .startTryOut, .getTryOutDetail, .submitAllAnswers, .finishTryOut, .getTryOutResult, .getPembahasan, .sendChatMessage, .getChatHistory:
      return true
    default:
      return false
    }
  }
  
  var baseURL: String {
    return "https://4928889e85cc.ngrok-free.app" // Ganti dengan base URL Anda
  }
  
  var path: String {
    switch self {
    case .register:
      return "/api/v1/auth/register"
    case .login:
      return "/api/v1/auth/login"
    case .getAllKelas(let page, let limit):
      return "/api/v1/kelas?page=\(page)&limit=\(limit)"
    case .getKelasDetail(let id):
      return "/api/v1/kelas/\(id)"
    case .getPaketsForKelas(let classId):
      return "/api/v1/kelas/\(classId)/pakets"
    case .createOrder:
      return "/api/v1/orders"
    case .getMyOrders(let page, let limit):
      return "/api/v1/orders/my-orders?page=\(page)&limit=\(limit)"
    case .startTryOut:
      return "/api/v1/tryouts/start"
    case .getTryOutDetail(let id):
      return "/api/v1/tryouts/\(id)"
    case .submitAllAnswers:
      return "/api/v1/tryouts/submit-all"
    case .finishTryOut:
      return "/api/v1/tryouts/finish"
    case .getTryOutResult(let id):
      return "/api/v1/tryouts/\(id)/results"
    case .getPembahasan(id: let id):
      return "/api/v1/tryouts/\(id)/pembahasan"
    case .sendChatMessage:
      return "/api/v1/chat/send"
    case .getChatHistory(let page, let limit, let soalId):
      return "/api/v1/chat/history?page=\(page)&limit=\(limit)&soal_id=\(soalId)"
    }
  }
  
  var url: URL? {
    return URL(string: baseURL + path)
  }
}
