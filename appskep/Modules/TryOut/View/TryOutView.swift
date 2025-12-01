import SwiftUI

struct TryOutView: View {
  let tryOutId: Int
  @StateObject private var viewModel = TryOutViewModel()
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  
  var body: some View {
    VStack {
      if viewModel.isLoading {
        VStack {
          ProgressView()
          Text("Memuat soal...")
            .padding(.top, 8)
            .foregroundColor(.secondary)
        }
      } else if let detail = viewModel.tryOutDetail, let soal = viewModel.currentSoal {
        VStack(spacing: 0) {
          headerView(paketName: detail.paket.name)
          
          ScrollView {
            questionView(soal: soal)
              .padding()
          }
          
          navigationButtons()
        }
      } else if let error = viewModel.errorMessage {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundColor(.orange)
          
          Text("Gagal memuat soal")
            .font(.headline)
          
          Text(error)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
          
          Button("Coba Lagi") {
            Task {
              await viewModel.fetchTryOutDetail(tryOutId: tryOutId)
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
    .ignoresSafeArea(.all) // Make fullscreen
    .navigationBarHidden(true) // Hide navigation bar completely
    .navigationBarBackButtonHidden(true) // Prevent back button
    .onAppear {
      print("🎯 TryOutView appeared with tryOutId: \(tryOutId)")
      viewModel.setCoordinator(tryOutCoordinator)
      Task {
        await viewModel.fetchTryOutDetail(tryOutId: tryOutId)
      }
    }
    .sheet(isPresented: $viewModel.showOverview) {
      if let detail = viewModel.tryOutDetail {
        TryOutOverviewSheet(
          totalSoal: detail.soals.count,
          answeredSoalIds: Set(viewModel.selectedAnswers.keys),
          soals: detail.soals,
          currentSoalIndex: $viewModel.currentSoalIndex
        )
      }
    }
    .alert("Selesaikan Try Out", isPresented: $viewModel.showFinishConfirmation) {
      Button("Batal", role: .cancel) {
        print("👤 User cancelled finish try out")
      }
      Button("Selesaikan") {
        print("👤 User confirmed finish try out")
        Task {
          await viewModel.finishTryOut()
        }
      }
    } message: {
      Text("Anda telah menjawab \(viewModel.answeredQuestionsCount) dari \(viewModel.totalQuestionsCount) soal. Apakah Anda yakin ingin menyelesaikan try out?")
    }
    .overlay {
      if viewModel.isSubmitting {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
        
        VStack(spacing: 16) {
          ProgressView()
            .scaleEffect(1.2)
          
          VStack(spacing: 8) {
            Text("Mengirim jawaban...")
              .font(.headline)
            
            Text("Mohon tunggu, jangan tutup aplikasi")
              .font(.caption)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
        }
        .padding(24)
        .background {
          RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(.regularMaterial)
        }
        .shadow(radius: 10)
      }
    }
    // Alert for errors during submission
    .alert("Error", isPresented: .constant(viewModel.errorMessage != nil && !viewModel.isSubmitting && !viewModel.isLoading)) {
      Button("OK") {
        viewModel.errorMessage = nil
      }
    } message: {
      if let error = viewModel.errorMessage {
        Text(error)
      }
    }
    // Prevent gesture back navigation
    .gesture(
      DragGesture()
        .onEnded { value in
          // Block swipe back gesture
          if value.translation.width > 100 {
            // Do nothing - prevent back navigation
            print("🚫 Back swipe gesture blocked")
          }
        }
    )
  }
  
  // Rest of the existing code remains the same...
  // (headerView, questionView, navigationButtons, helper functions)
  
  private func headerView(paketName: String) -> some View {
    VStack(spacing: 12) {
      // Status bar area padding
      Rectangle()
        .fill(Color.clear)
        .frame(height: getSafeAreaTop())
      
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(paketName)
            .font(.headline)
            .lineLimit(2)
          
          Text(viewModel.timeRemainingFormatted)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Button(action: {
          print("👤 User opened overview")
          viewModel.showOverview = true
        }) {
          Image(systemName: "square.grid.2x2.fill")
            .font(.title2)
            .foregroundColor(.main)
        }
      }
      .padding(.horizontal)
      
      // Progress bar
      VStack(spacing: 8) {
        ProgressView(value: Double(viewModel.answeredQuestionsCount),
                     total: Double(viewModel.totalQuestionsCount))
          .progressViewStyle(LinearProgressViewStyle(tint: .main))
        
        HStack {
          Text("Terjawab: \(viewModel.answeredQuestionsCount)/\(viewModel.totalQuestionsCount)")
            .font(.caption)
            .foregroundColor(.secondary)
          Spacer()
        }
      }
      .padding(.horizontal)
      
      Divider()
    }
    .background(Color(.systemBackground))
  }
  
  private func questionView(soal: Soal) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(viewModel.progressText)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Text(soal.question)
        .font(.body)
        .lineSpacing(5)
      
      ForEach(Array(soal.pilihan_jawaban.enumerated()), id: \.element.id) { index, option in
        let optionChar = Character(UnicodeScalar(65 + index)!)
        AnswerOptionView(
          option: option,
          index: optionChar,
          isSelected: viewModel.isSelected(option: option)
        )
        .onTapGesture {
          print("👤 User selected option \(optionChar) for soal \(soal.id)")
          viewModel.selectAnswer(optionId: option.id)
        }
      }
      
      // Doubt button
      Button(action: {
        print("👤 User toggled doubt for soal \(soal.id)")
        viewModel.toggleDoubt()
      }) {
        HStack {
          Image(systemName: viewModel.isCurrentSoalMarkedAsDoubt() ? "flag.fill" : "flag")
          Text(viewModel.isCurrentSoalMarkedAsDoubt() ? "Sudah ditandai ragu" : "Tandai sebagai ragu")
        }
        .foregroundColor(viewModel.isCurrentSoalMarkedAsDoubt() ? .orange : .secondary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
      }
      
      // Bottom padding untuk safe area
      Rectangle()
        .fill(Color.clear)
        .frame(height: 100)
    }
  }
  
  private func navigationButtons() -> some View {
    VStack(spacing: 0) {
      Divider()
      
      HStack {
        Button(action: {
          print("👤 User went to previous question")
          viewModel.goToPreviousSoal()
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
          if viewModel.isLastSoal {
            print("👤 User clicked finish button")
            viewModel.showFinishTryOutConfirmation()
          } else {
            print("👤 User went to next question")
            viewModel.goToNextSoal()
          }
        }) {
          Text(viewModel.isLastSoal ? "Selesai" : "Selanjutnya ›")
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              viewModel.isLastSoal ? (viewModel.canFinishTryOut ? Color.main : Color(.systemGray4)) : Color.main
            )
            .foregroundColor(
              viewModel.isLastSoal ? (viewModel.canFinishTryOut ? .white : Color.white.opacity(0.8)) : .white
            )
            .cornerRadius(12)
        }
        .disabled(viewModel.isLastSoal ? !viewModel.canFinishTryOut : false)
      }
      .padding()
      
      // Bottom safe area padding
      Rectangle()
        .fill(Color(.systemBackground))
        .frame(height: getSafeAreaBottom())
    }
    .background(Color(.systemBackground))
  }
  
  // MARK: - Helper Functions
  private func getSafeAreaTop() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      return 44 // Default status bar height
    }
    return window.safeAreaInsets.top
  }
  
  private func getSafeAreaBottom() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      return 34 // Default bottom safe area for devices with home indicator
    }
    return window.safeAreaInsets.bottom
  }
}

#Preview {
  TryOutView(tryOutId: 69)
}
