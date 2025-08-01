import SwiftUI

struct TryOutResultView: View {
  let result: TryOutResult
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  @State private var showConfetti = false
  @State private var animateScore = false
  
  // Computed properties for statistics
  private var totalQuestions: Int {
    result.soals.count
  }
  
  private var correctAnswers: Int {
    result.answers.filter { answer in
      answer.pilihan_jawaban.is_correct
    }.count
  }
  
  private var wrongAnswers: Int {
    totalQuestions - correctAnswers
  }
  
  private var duration: String {
    let startDate = parseDate(result.started_at)
    let endDate = parseDate(result.finished_at)
    
    if let start = startDate, let end = endDate {
      let interval = end.timeIntervalSince(start)
      let minutes = Int(interval) / 60
      let seconds = Int(interval) % 60
      return "\(minutes) menit \(seconds) detik"
    }
    return "N/A"
  }
  
  private var scoreCategory: (title: String, color: Color, icon: String) {
    switch result.score {
    case 90...100:
      return ("Excellent!", .green, "star.fill")
    case 80..<90:
      return ("Very Good!", .blue, "checkmark.seal.fill")
    case 70..<80:
      return ("Good!", .orange, "checkmark.circle.fill")
    case 60..<70:
      return ("Fair", .yellow, "exclamationmark.circle.fill")
    default:
      return ("Need Improvement", .red, "xmark.circle.fill")
    }
  }
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: 32) {
          // Header with score
          scoreHeaderView
          
          // Statistics cards
          statisticsView
          
          // Duration info
          durationView
          
          // Action buttons
          actionButtonsView
          
          // Bottom spacing for safe area
          Rectangle()
            .fill(Color.clear)
            .frame(height: getSafeAreaBottom() + 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, getSafeAreaTop() + 20)
      }
      .background(
        LinearGradient(
          colors: [Color(.systemBackground), scoreCategory.color.opacity(0.1)],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
      )
      .overlay(
        // Confetti overlay for high scores
        Group {
          if showConfetti && result.score >= 80 {
            ConfettiView()
              .allowsHitTesting(false)
          }
        }
      )
    }
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    .onAppear {
      startAnimations()
    }
    .gesture(
      // Prevent swipe back
      DragGesture()
        .onEnded { _ in }
    )
  }
  
  private var scoreHeaderView: some View {
    VStack(spacing: 20) {
      // Score display
      VStack(spacing: 16) {
        Image(systemName: scoreCategory.icon)
          .font(.system(size: 60))
          .foregroundColor(scoreCategory.color)
          .scaleEffect(animateScore ? 1.2 : 1.0)
          .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateScore)
        
        Text(scoreCategory.title)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(scoreCategory.color)
        
        // Score circle
        ZStack {
          Circle()
            .stroke(scoreCategory.color.opacity(0.2), lineWidth: 8)
            .frame(width: 120, height: 120)
          
          Circle()
            .trim(from: 0, to: animateScore ? CGFloat(result.score) / 100 : 0)
            .stroke(scoreCategory.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .frame(width: 120, height: 120)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1.5), value: animateScore)
          
          Text("\(result.score)")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(scoreCategory.color)
        }
        
        Text("Skor Anda")
          .font(.headline)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private var statisticsView: some View {
    VStack(spacing: 16) {
      Text("Statistik Jawaban")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      HStack(spacing: 16) {
        // Correct answers
        StatCard(
          icon: "checkmark.circle.fill",
          title: "Benar",
          value: "\(correctAnswers)",
          color: .green
        )
        
        // Wrong answers
        StatCard(
          icon: "xmark.circle.fill",
          title: "Salah",
          value: "\(wrongAnswers)",
          color: .red
        )
        
        // Total questions
        StatCard(
          icon: "doc.text.fill",
          title: "Total Soal",
          value: "\(totalQuestions)",
          color: .blue
        )
      }
    }
  }
  
  private var durationView: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "clock.fill")
          .foregroundColor(.orange)
        Text("Durasi Pengerjaan")
          .font(.headline)
        Spacer()
      }
      
      HStack {
        Text(duration)
          .font(.title3)
          .fontWeight(.semibold)
        Spacer()
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var actionButtonsView: some View {
    VStack(spacing: 16) {
      // Review answers button (disabled for now)
      Button(action: {
        // TODO: Implement review functionality
      }) {
        HStack {
          Image(systemName: "doc.text.magnifyingglass")
          Text("Lihat Pembahasan")
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.gray) // Disabled color
        .cornerRadius(16)
      }
      .disabled(true) // Will be enabled later
      
      // Back to home button
      Button(action: navigateToHome) {
        HStack {
          Image(systemName: "house.fill")
          Text("Kembali ke Beranda")
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.main)
        .cornerRadius(16)
      }
    }
  }
  
  // MARK: - Helper Methods
  
  private func startAnimations() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      withAnimation {
        animateScore = true
      }
    }
    
    if result.score >= 80 {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        showConfetti = true
      }
    }
  }
  
  private func navigateToHome() {
    print("🏠 TryOutResultView: Calling backToHome() on coordinator")
    withAnimation(.easeInOut(duration: 0.5)) {
      tryOutCoordinator.backToHome()
    }
  }
  
  private func parseDate(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.date(from: dateString)
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

// MARK: - Supporting Views

struct StatCard: View {
  let icon: String
  let title: String
  let value: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(color)
      
      Text(value)
        .font(.title2)
        .fontWeight(.bold)
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
  }
}

struct ConfettiView: View {
  @State private var animate = false
  
  var body: some View {
    ZStack {
      ForEach(0..<50, id: \.self) { _ in
        Circle()
          .fill(Color.random)
          .frame(width: 8, height: 8)
          .position(
            x: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.width) : UIScreen.main.bounds.width / 2,
            y: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : -50
          )
          .animation(
            .easeOut(duration: Double.random(in: 2...4))
            .delay(Double.random(in: 0...2)),
            value: animate
          )
      }
    }
    .onAppear {
      animate = true
    }
  }
}

extension Color {
  static var random: Color {
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    return colors.randomElement() ?? .blue
  }
}

#Preview {
  TryOutResultView(
    result: TryOutResult(
      id: 1,
      order_id: 1,
      paket_id: 1,
      started_at: "2025-08-01 21:13:41",
      finished_at: "2025-08-01 21:43:47",
      score: 85,
      paket: Paket(id: 1, name: "Try Out Komprehensif UKOM", description: "Test", duration: 150),
      soals: [],
      answers: []
    )
  )
  .environmentObject(TryOutCoordinator())
}
