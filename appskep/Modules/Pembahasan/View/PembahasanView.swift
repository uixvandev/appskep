//
//  PembahasanView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct PembahasanView: View {
  let tryOutId: Int
  @StateObject private var viewModel = PembahasanViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showOverview = false
  @State private var showChatBot = false
  
  var body: some View {
    VStack {
      if viewModel.isLoading {
        VStack {
          ProgressView()
          Text("Memuat pembahasan...")
            .padding(.top, 8)
            .foregroundColor(.secondary)
        }
      } else if let question = viewModel.currentQuestion {
        VStack(spacing: 0) {
          headerView
          
          ScrollView {
            pembahasanQuestionView(question: question)
              .padding()
          }
          
          navigationButtons(question: question) // Pass question as parameter
        }
      } else if let errorMessage = viewModel.errorMessage {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundColor(.orange)
          
          Text("Gagal memuat pembahasan")
            .font(.headline)
          
          Text(errorMessage)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
          
          Button("Coba Lagi") {
            Task {
              await viewModel.fetchPembahasan(tryOutId: tryOutId)
            }
          }
          .padding()
          .background(Color.main)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
        .padding()
      }
    }
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    .onAppear {
      Task {
        await viewModel.fetchPembahasan(tryOutId: tryOutId)
      }
    }
    .sheet(isPresented: $showOverview) {
      if let questions = viewModel.pembahasanData?.questions {
        PembahasanOverviewSheet(
          questions: questions,
          currentQuestionIndex: $viewModel.currentQuestionIndex
        )
      }
    }
    .fullScreenCover(isPresented: $showChatBot) {
      // Fix: Use viewModel.currentQuestion instead of question
      if let currentQuestion = viewModel.currentQuestion {
        NavigationStack {
          ChatBotView(question: currentQuestion)
        }
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
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Pembahasan Try Out")
            .font(.headline)
            .lineLimit(1)
          
          if let resultsData = viewModel.resultsData {
            Text("\(resultsData.paket_name)")
              .font(.caption)
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
        }
        
        Spacer()
        
        Button(action: {
          showOverview = true
        }) {
          Image(systemName: "square.grid.2x2.fill")
            .font(.title2)
            .foregroundColor(.main)
        }
      }
      .padding(.horizontal)
      
      // Progress info
      VStack(spacing: 8) {
        HStack {
          Text(viewModel.progressText)
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
          if let resultsData = viewModel.resultsData {
            Text("Skor: \(resultsData.score)")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundColor(.main)
          }
        }
      }
      .padding(.horizontal)
      
      Divider()
    }
    .background(Color(.systemBackground))
  }
  
  private func pembahasanQuestionView(question: PembahasanQuestion) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      // Question
      Text(question.question)
        .font(.body)
        .lineSpacing(5)
      
      // Options with user's answer and correct answer indication
      ForEach(Array(question.all_options.enumerated()), id: \.element.id) { index, option in
        let optionChar = Character(UnicodeScalar(65 + index)!)
        PembahasanOptionView(
          option: option,
          index: optionChar,
          isUserAnswer: option.id == question.user_answer.pilihan_jawaban_id,
          isCorrectAnswer: option.is_correct
        )
      }
      
      // Result indicator
      HStack {
        Image(systemName: question.is_user_correct ? "checkmark.circle.fill" : "xmark.circle.fill")
          .foregroundColor(question.is_user_correct ? .green : .red)
        
        Text(question.is_user_correct ? "Jawaban Anda Benar!" : "Jawaban Anda Salah")
          .font(.headline)
          .foregroundColor(question.is_user_correct ? .green : .red)
        
        Spacer()
      }
      .padding()
      .background(question.is_user_correct ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
      .cornerRadius(12)
      
      // Explanation
      VStack(alignment: .leading, spacing: 8) {
        Text("Pembahasan:")
          .font(.headline)
          .foregroundColor(.main)
        
        Text(question.explanation)
          .font(.body)
          .lineSpacing(4)
      }
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(12)
      
      // Bottom padding
      Rectangle()
        .fill(Color.clear)
        .frame(height: 100)
    }
  }
  
  private func navigationButtons(question: PembahasanQuestion) -> some View {
    VStack(spacing: 0) {
      Divider()
      
      // Chat Bot Button
      Button(action: {
        showChatBot = true
      }) {
        HStack {
          Image(systemName: "bubble.left.and.bubble.right.fill")
            .font(.title3)
          Text("Tanya Askep")
            .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
          LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(12)
      }
      .padding(.horizontal)
      .padding(.top, 8)
      
      // Navigation Buttons
      HStack {
        Button(action: {
          viewModel.goToPreviousQuestion()
        }) {
          Text("‹ Sebelumnya")
            .padding()
            .frame(maxWidth: .infinity)
            .background(viewModel.canGoToPrevious ? Color.main.opacity(0.1) : Color(.systemGray5))
            .foregroundColor(viewModel.canGoToPrevious ? .main : .secondary)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canGoToPrevious)
        
        Button(action: {
          if viewModel.isLastQuestion {
            dismiss()
          } else {
            viewModel.goToNextQuestion()
          }
        }) {
          Text(viewModel.isLastQuestion ? "Selesai" : "Selanjutnya ›")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.main)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
      }
      .padding()
      
      // Bottom safe area padding
      Rectangle()
        .fill(Color(.systemBackground))
        .frame(height: getSafeAreaBottom())
    }
    .background(Color(.systemBackground))
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
  PembahasanView(tryOutId: 128)
}
