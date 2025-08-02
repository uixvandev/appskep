//
//  ChatBotViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable {
    let id: Int
    let content: String
    let isUser: Bool
    let timestamp: Date
    let originalHistoryId: Int? // Track original message ID for deletion
}

@MainActor
class ChatBotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var isLoadingHistory = false
    @Published var errorMessage: String?
    @Published var isDeletingMessage = false
    
    private var currentSoalId: Int?
    private var hasLoadedHistory = false
    
    func loadChatHistory(soalId: Int) async {
        guard !hasLoadedHistory else { return }
        
        currentSoalId = soalId
        isLoadingHistory = true
        
        do {
            let response: ChatHistoryResponse = try await APIService.shared.performRequest(
                endpoint: .getChatHistory(page: 1, limit: 50, soalId: soalId),
                method: .GET,
                responseType: ChatHistoryResponse.self
            )
            
            if response.success {
                let historyMessages = response.data.messages.flatMap { historyMessage -> [ChatMessage] in
                    let userMessage = ChatMessage(
                        id: historyMessage.id * 1000, // Ensure unique ID
                        content: historyMessage.message,
                        isUser: true,
                        timestamp: parseDate(historyMessage.created_at) ?? Date(),
                        originalHistoryId: historyMessage.id
                    )
                    
                    let botMessage = ChatMessage(
                        id: historyMessage.id,
                        content: historyMessage.response,
                        isUser: false,
                        timestamp: parseDate(historyMessage.created_at) ?? Date(),
                        originalHistoryId: historyMessage.id
                    )
                    
                    return [userMessage, botMessage]
                }.sorted { $0.timestamp < $1.timestamp }
                
                messages = historyMessages
                hasLoadedHistory = true
            }
        } catch {
            print("Failed to load chat history: \(error)")
        }
        
        isLoadingHistory = false
    }
    
    func sendMessage(_ message: String, soalId: Int) async {
        // Add user message
        let userMessage = ChatMessage(
            id: Int(Date().timeIntervalSince1970 * 1000), // Unique timestamp-based ID
            content: message,
            isUser: true,
            timestamp: Date(),
            originalHistoryId: nil // New messages don't have history ID yet
        )
        messages.append(userMessage)
        
        isLoading = true
        errorMessage = nil
        
        let request = ChatRequest(message: message, soal_id: soalId)
        
        do {
            let bodyData = try JSONEncoder().encode(request)
            
            let response: ChatResponse = try await APIService.shared.performRequest(
                endpoint: .sendChatMessage,
                method: .POST,
                body: bodyData,
                responseType: ChatResponse.self
            )
            
            if response.success {
                // Update user message with history ID
                if let userIndex = messages.firstIndex(where: { $0.id == userMessage.id }) {
                    messages[userIndex] = ChatMessage(
                        id: userMessage.id,
                        content: userMessage.content,
                        isUser: true,
                        timestamp: userMessage.timestamp,
                        originalHistoryId: response.data.id
                    )
                }
                
                let botMessage = ChatMessage(
                    id: response.data.id,
                    content: response.data.response,
                    isUser: false,
                    timestamp: parseDate(response.data.created_at) ?? Date(),
                    originalHistoryId: response.data.id
                )
                messages.append(botMessage)
            } else {
                errorMessage = response.message
                showErrorMessage()
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorMessage()
        }
        
        isLoading = false
    }
    
    func deleteMessage(_ message: ChatMessage) async {
        guard let historyId = message.originalHistoryId else {
            print("Cannot delete message without history ID")
            return
        }
        
        isDeletingMessage = true
        
        do {
            let response: ChatDeleteResponse = try await APIService.shared.performRequest(
                endpoint: .deleteChatMessage(id: historyId),
                method: .DELETE,
                responseType: ChatDeleteResponse.self
            )
            
            if response.success {
                // Remove both user and bot messages with the same history ID
                withAnimation(.easeInOut(duration: 0.3)) {
                    messages.removeAll { msg in
                        msg.originalHistoryId == historyId
                    }
                }
            } else {
                errorMessage = response.message
                showErrorMessage()
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorMessage()
        }
        
        isDeletingMessage = false
    }
    
    func clearAllHistory() async {
      guard currentSoalId != nil else { return }
        
        isDeletingMessage = true
        
        // Get all unique history IDs
        let historyIds = Set(messages.compactMap { $0.originalHistoryId })
        
        // Delete all messages one by one
        for historyId in historyIds {
            do {
                let response: ChatDeleteResponse = try await APIService.shared.performRequest(
                    endpoint: .deleteChatMessage(id: historyId),
                    method: .DELETE,
                    responseType: ChatDeleteResponse.self
                )
                
                if !response.success {
                    print("Failed to delete message with ID: \(historyId)")
                }
            } catch {
                print("Error deleting message with ID \(historyId): \(error)")
            }
        }
        
        // Clear UI
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.removeAll()
            hasLoadedHistory = false
        }
        
        isDeletingMessage = false
    }
    
    private func showErrorMessage() {
        if let error = errorMessage {
            let errorBotMessage = ChatMessage(
                id: Int(Date().timeIntervalSince1970 * 1000),
                content: "Maaf, terjadi kesalahan: \(error). Silakan coba lagi.",
                isUser: false,
                timestamp: Date(),
                originalHistoryId: nil
            )
            messages.append(errorBotMessage)
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }
    
    // Keep old clearHistory for UI-only clearing if needed
    func clearHistory() {
        messages.removeAll()
        hasLoadedHistory = false
    }
}
