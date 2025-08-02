//
//  ChatBotView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct ChatBotView: View {
    let question: PembahasanQuestion
    @StateObject private var viewModel = ChatBotViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Question context card
                        questionContextCard
                        
                        // Loading history indicator
                        if viewModel.isLoadingHistory {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Memuat riwayat chat...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // History divider if there are messages
                        if !viewModel.messages.isEmpty && !viewModel.isLoadingHistory {
                            HStack {
                                VStack { Divider() }
                                Text("Riwayat Chat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                VStack { Divider() }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Chat messages
                        ForEach(viewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                        
                        // Loading indicator for new messages
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Askep sedang mengetik...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Empty state message
                        if viewModel.messages.isEmpty && !viewModel.isLoadingHistory {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("Mulai Percakapan")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Tanyakan apa saja tentang soal ini ke Askep!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            messageInputView
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await viewModel.loadChatHistory(soalId: question.soal_id)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Status bar area padding
            Rectangle()
                .fill(Color.clear)
                .frame(height: getSafeAreaTop())
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.main)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.main)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chat dengan Askep")
                            .font(.headline)
                        Text("Asisten AI Keperawatan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Clear history button
                if !viewModel.messages.isEmpty {
                    Button(action: {
                        withAnimation {
                            viewModel.clearHistory()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private var questionContextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Soal yang dibahas:")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Text("ID: \(question.soal_id)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(question.question)
                .font(.body)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            if viewModel.messages.isEmpty && !viewModel.isLoadingHistory {
                Text("Kamu bisa bertanya apa saja tentang soal ini!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Tanya Askep tentang soal ini...", text: $messageText, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.main)
                        .cornerRadius(22)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Bottom safe area padding
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(height: getSafeAreaBottom())
        }
    }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        messageText = ""
        isTextFieldFocused = false
        
        Task {
            await viewModel.sendMessage(message, soalId: question.soal_id)
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 44
        }
        return window.safeAreaInsets.top
    }
    
    private func getSafeAreaBottom() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 34
        }
        return window.safeAreaInsets.bottom
    }
}

#Preview {
    ChatBotView(
        question: PembahasanQuestion(
            soal_id: 1,
            question: "Apa tindakan pertama pada pasien henti napas?",
            user_answer: UserAnswer(pilihan_jawaban_id: 3, option_text: "Lakukan RJP", is_correct: true),
            correct_answer: CorrectAnswer(pilihan_jawaban_id: 3, option_text: "Lakukan RJP", is_correct: true),
            all_options: [],
            explanation: "Resusitasi jantung paru (RJP) adalah prioritas utama untuk mengembalikan sirkulasi dan oksigenasi.",
            is_user_correct: true,
            category: "General"
        )
    )
}
