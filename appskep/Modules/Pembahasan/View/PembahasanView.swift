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
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  @State private var showOverview = false
  @State private var showChatBot = false
  
  var body: some View {
      ZStack {
        // Background color
        Color(.systemGray6)
          .ignoresSafeArea(.all)
        
        VStack(spacing: 0) {
          if viewModel.isLoading {
            // Loading state - centered
            VStack(spacing: 16) {
              ProgressView()
                .scaleEffect(1.2)
              Text("Memuat pembahasan...")
                .font(.headline)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
          } else if let question = viewModel.currentQuestion {
            // Header (fixed at top)
            headerView
            
            // Content (scrollable)
            ScrollView {
              VStack(spacing: 20) {
                pembahasanQuestionView(question: question)
                
                // Bottom spacing for navigation buttons
                Rectangle()
                  .fill(Color.clear)
                  .frame(height: 100)
              }
              .padding(.top, 16)
            }
            
            // Navigation buttons (fixed at bottom)
            navigationButtons(question: question)
            
          } else if let errorMessage = viewModel.errorMessage {
            // Error state - centered
            VStack(spacing: 20) {
              Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
              
              Text("Gagal memuat pembahasan")
                .font(.title2)
                .fontWeight(.bold)
              
              Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
              
              Button("Coba Lagi") {
                Task {
                  await viewModel.fetchPembahasan(tryOutId: tryOutId)
                }
              }
              .font(.headline)
              .foregroundColor(.white)
              .frame(width: 140, height: 44)
              .background(Color.blue)
              .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
      }
      .ignoresSafeArea(.all)
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
        if let currentQuestion = viewModel.currentQuestion {
          NavigationStack {
            ChatBotView(question: currentQuestion)
          }
        }
      }
    }
  
  // MARK: - UI Components
  private var headerView: some View {
      VStack(spacing: 0) {
        // Status bar area padding
        Rectangle()
          .fill(Color(.systemBackground))
          .frame(height: getSafeAreaTop())
        
        // Header content
        HStack(spacing: 16) {
          Button(action: {
            // Prefer environment dismiss to support both modal & push
            dismiss()
          }) {
            Image(systemName: "chevron.left")
              .font(.title2)
              .foregroundColor(.primary)
          }
          
          VStack(alignment: .leading, spacing: 2) {
            Text("Try Out Part 1")
              .font(.headline)
              .fontWeight(.semibold)
              .lineLimit(1)
            
            Text(viewModel.progressText)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          
          Spacer()
          
          Button(action: {
            showOverview = true
          }) {
            Image(systemName: "square.grid.2x2")
              .font(.title2)
              .foregroundColor(.blue)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
      }
    }
  
  private func pembahasanQuestionView(question: PembahasanQuestion) -> some View {
      VStack(alignment: .leading, spacing: 24) {
        // Question text
        Text(question.question)
          .font(.body)
          .lineSpacing(6)
          .fixedSize(horizontal: false, vertical: true)
        
        // Answer options
        VStack(spacing: 16) {
          ForEach(Array(question.all_options.enumerated()), id: \.element.id) { index, option in
            let optionChar = Character(UnicodeScalar(65 + index)!)
            AnswerOptionCard(
              option: option,
              index: optionChar,
              isUserAnswer: option.id == question.user_answer?.pilihan_jawaban_id,
              isCorrectAnswer: option.is_correct
            )
          }
        }
        
        // User's answer status
        UserAnswerStatusCard(
          isCorrect: question.is_user_correct,
          userAnswerText: question.user_answer?.option_text ?? "Tidak dijawab"
        )
        
        // Explanation section
        ExplanationCard(explanation: question.explanation)
      }
      .padding(.horizontal, 20)
    }
  
  //Navigation button
  private func navigationButtons(question: PembahasanQuestion) -> some View {
    VStack(spacing: 0) {
      // Navigation Buttons - 3 buttons in HStack
      HStack(spacing: 16) {
        // Previous Button (Left Arrow)
        Button(action: {
          viewModel.goToPreviousQuestion()
        }) {
          Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(viewModel.canGoToPrevious ? .primary : .secondary)
            .frame(width: 50, height: 50)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .disabled(!viewModel.canGoToPrevious)
        
        // Chat Bot Button (Center)
        Button(action: {
          showChatBot = true
        }) {
          HStack(spacing: 12) {
              Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tanya chatbot")
              .font(.headline)
              .fontWeight(.medium)
              .foregroundColor(.white)
          }
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(
            LinearGradient(
              colors: [Color.blue, Color.cyan],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .cornerRadius(28) // Make it more rounded like in the image
        }
        
        // Next Button (Right Arrow)
        Button(action: {
          if viewModel.isLastQuestion {
            // Prefer environment dismiss to support both modal & push
            dismiss()
          } else {
            viewModel.goToNextQuestion()
          }
        }) {
          Image(systemName: "chevron.right")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.primary)
            .frame(width: 50, height: 50)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
      }
      .padding(.horizontal, 20)
      .padding(.bottom, getSafeAreaBottom() + 16)
      .background(Color(.systemGray6))
    }
  }
  
  // MARK: - Helper Functions
  
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

// MARK: - Supporting Views

struct AnswerOptionCard: View {
  let option: PembahasanOption
  let index: Character
  let isUserAnswer: Bool
  let isCorrectAnswer: Bool
  
  private var backgroundColor: Color {
    if isCorrectAnswer {
      return Color(.systemBackground)
    } else if isUserAnswer && !isCorrectAnswer {
      return Color(.systemBackground)
    } else {
      return Color(.systemBackground)
    }
  }
  
  private var borderColor: Color {
    if isCorrectAnswer {
      return Color.green
    } else if isUserAnswer && !isCorrectAnswer {
      return Color.red
    } else {
      return Color(.systemGray4)
    }
  }
  
  private var indexColor: Color {
    if isCorrectAnswer {
      return Color.green
    } else if isUserAnswer && !isCorrectAnswer {
      return Color.red
    } else {
      return Color.gray
    }
  }
  
  var body: some View {
    HStack(spacing: 16) {
      // Option index
      Text(String(index))
        .font(.headline)
        .fontWeight(.bold)
        .frame(width: 28, height: 28)
        .background(indexColor)
        .foregroundColor(.white)
        .clipShape(Circle())
      
      // Option text
      Text(option.option_text)
        .font(.body)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Spacer()
    }
    .padding(16)
    .background(backgroundColor)
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(borderColor, lineWidth: 2)
    )
  }
}

struct UserAnswerStatusCard: View {
  let isCorrect: Bool
  let userAnswerText: String
  
  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
          .frame(width: 32, height: 32)
        
        Image(systemName: isCorrect ? "checkmark" : "xmark")
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(isCorrect ? .green : .red)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(isCorrect ? "Jawaban kamu benar" : "Jawaban kamu salah")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(isCorrect ? .green : .red)
        
        if !isCorrect {
          Text("Jawaban kamu: \(userAnswerText)")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
    }
    .padding(16)
    .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
    .cornerRadius(16)
  }
}

struct ExplanationCard: View {
  let explanation: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Pembahasan")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
      
      Text(explanation)
        .font(.body)
        .lineSpacing(6)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.primary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(Color(.systemGray5))
    .cornerRadius(16)
  }
}

#Preview {
  PembahasanView(tryOutId: 128)
}
