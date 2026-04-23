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
  case getKelasDetail(classCode: String)
  case getPaketsForKelas(classCode: String)
  case createOrder
  case getMyOrders(page: Int, limit: Int)
  case startTryOut
  case getTryOutDetail(tryoutCode: String)
  case submitAllAnswers
  case finishTryOut
  case getTryOutResult(tryoutCode: String)
  case getPembahasan(tryoutCode: String)
  case sendChatMessage
  case getChatHistory(page: Int, limit: Int, questionCode: String)
  case deleteChatMessage(id: Int)
  case getTryOutHistory(page: Int, limit: Int)
  case getNotifications(page: Int, limit: Int)
  case getUnreadCount
  case markNotificationAsRead(id: Int)
  case getOrderHistory(page: Int, limit: Int)
  case getOrderDetail(orderNumber: String)
  case checkClassAccess(classCode: String)
  case checkRetryEligibility(orderNumber: String, packageCode: String)
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
    return "https://92ee-182-9-193-52.ngrok-free.app" // Ganti dengan base URL Anda
  }
  
  var path: String {
    switch self {
    case .register:
      return "/api/v1/auth/register"
    case .login:
      return "/api/v1/auth/login"
    case .getAllKelas(let page, let limit):
      return "/api/v1/kelas?page=\(page)&limit=\(limit)"
    case .getKelasDetail(let classCode):
      return "/api/v1/kelas/\(classCode)"
    case .getPaketsForKelas(let classCode):
      return "/api/v1/kelas/\(classCode)/pakets"
    case .createOrder:
      return "/api/v1/orders"
    case .getMyOrders(let page, let limit):
      return "/api/v1/orders/my-orders?page=\(page)&limit=\(limit)"
    case .startTryOut:
      return "/api/v1/tryouts/start"
    case .getTryOutDetail(let tryoutCode):
      return "/api/v1/tryouts/\(tryoutCode)"
    case .submitAllAnswers:
      return "/api/v1/tryouts/submit-all"
    case .finishTryOut:
      return "/api/v1/tryouts/finish"
    case .getTryOutResult(let tryoutCode):
      return "/api/v1/tryouts/\(tryoutCode)/results"
    case .getPembahasan(let tryoutCode):
      return "/api/v1/tryouts/\(tryoutCode)/pembahasan"
    case .sendChatMessage:
      return "/api/v1/chat/send"
    case .getChatHistory(let page, let limit, let questionCode):
      return "/api/v1/chat/history?page=\(page)&limit=\(limit)&question_code=\(questionCode)"
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
    case .getOrderDetail(let orderNumber):
      return "/api/v1/orders/\(orderNumber)"
    case .checkClassAccess(let classCode):
      return "/api/v1/orders/check-access/\(classCode)"
    case .checkRetryEligibility(let orderNumber, let packageCode):
      return "/api/v1/tryouts/check-retry?order_number=\(orderNumber)&package_code=\(packageCode)"
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
