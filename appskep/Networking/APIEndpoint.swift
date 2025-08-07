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
  case deleteChatMessage(id: Int)
  case getTryOutHistory(page: Int, limit: Int)
  case getNotifications(page: Int, limit: Int)
  case getUnreadCount
  case markNotificationAsRead(id: Int)
  case getOrderHistory(page: Int, limit: Int)
  case getOrderDetail(id: Int)
  case checkClassAccess(kelasId: Int)
  case checkRetryEligibility(orderId: Int, paketId: Int)
  case updateProfile
  case changePassword
  
  var requiresAuth: Bool {
    switch self {
    case .createOrder, .getMyOrders, .startTryOut, .getTryOutDetail, .submitAllAnswers, .finishTryOut, .getTryOutResult, .getPembahasan, .sendChatMessage, .getChatHistory, .deleteChatMessage, .getTryOutHistory, .getNotifications, .getUnreadCount, .markNotificationAsRead, .getOrderHistory, .getOrderDetail, .checkClassAccess, .checkRetryEligibility, .updateProfile, .changePassword:
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
    case .deleteChatMessage(let id):
      return "/api/v1/chat/history/\(id)"
    case .getTryOutHistory(let page, let limit):
      return "/api/v1/tryouts/history?page=\(page)&limit=\(limit)"
    case .getNotifications(let page, let limit):
      return "/api/v1/notifications?page=\(page)&limit=\(limit)"
    case .getUnreadCount:
      return "/api/v1/notifications/unread-count"
    case .markNotificationAsRead(let id):
      return "/api/v1/notifications/\(id)/read"
    case .getOrderHistory(let page, let limit):
      return "/api/v1/orders/my-orders?page=\(page)&limit=\(limit)"
    case .getOrderDetail(let id):
      return "/api/v1/orders/\(id)"
    case .checkClassAccess(let kelasId):
      return "/api/v1/orders/check-access/\(kelasId)"
    case .checkRetryEligibility(let orderId, let paketId):
      return "/api/v1/tryouts/check-retry?order_id=\(orderId)&paket_id=\(paketId)"
    case .updateProfile:
      return "/api/v1/users/profile"
    case .changePassword:
      return "/api/v1/users/change-password"
    }
  }
  
  var url: URL? {
    return URL(string: baseURL + path)
  }
}
