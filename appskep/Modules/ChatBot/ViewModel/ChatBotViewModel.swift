//
//  ChatBotViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: Int
    let content: String
    let isUser: Bool
    let timestamp: Date
}

@MainActor
class ChatBotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var isLoadingHistory = false
    @Published var errorMessage: String?
    
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
                        timestamp: parseDate(historyMessage.created_at) ?? Date()
                    )
                    
                    let botMessage = ChatMessage(
                        id: historyMessage.id,
                        content: historyMessage.response,
                        isUser: false,
                        timestamp: parseDate(historyMessage.created_at) ?? Date()
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
            timestamp: Date()
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
                let botMessage = ChatMessage(
                    id: response.data.id,
                    content: response.data.response,
                    isUser: false,
                    timestamp: parseDate(response.data.created_at) ?? Date()
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
    
    private func showErrorMessage() {
        if let error = errorMessage {
            let errorBotMessage = ChatMessage(
                id: Int(Date().timeIntervalSince1970 * 1000),
                content: "Maaf, terjadi kesalahan: \(error). Silakan coba lagi.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorBotMessage)
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }
    
    func clearHistory() {
        messages.removeAll()
        hasLoadedHistory = false
    }
}
