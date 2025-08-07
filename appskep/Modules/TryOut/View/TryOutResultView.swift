import SwiftUI

struct TryOutResultView: View {
  let result: TryOutResult
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  @State private var showPembahasan = false
  
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
      return "\(minutes) Menit"
    }
    return "N/A"
  }
  
  var body: some View {
    ZStack {
      // Background Gradient
      LinearGradient(
        colors: [Color.blue.opacity(0.1), Color(.systemBackground)],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 24) {
          // Top Illustration
          Image(systemName: "rosette") // Placeholder, ganti dengan gambar Anda
            .font(.system(size: 100))
            .foregroundColor(.blue)
            .padding(.top, 40)
          
          // Title
          Text("Selamat!")
            .font(.largeTitle)
            .fontWeight(.bold)
          
          // Subtitle
          Text("Kamu telah menyelesaikan \(result.paket.name)")
            .font(.headline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
          
          // Score Circle
          scoreCircleView
            .padding(.vertical, 20)
          
          // Summary Card
          summaryCardView
          
          // Action Buttons
          actionButtonsView
            .padding(.top, 20)
        }
        .padding()
      }
    }
    .navigationBarHidden(true)
    .navigationBarBackButtonHidden(true)
    .fullScreenCover(isPresented: $showPembahasan) {
      NavigationStack {
        PembahasanView(tryOutId: result.id)
      }
    }
  }
  
  private var scoreCircleView: some View {
    ZStack {
      Circle()
        .stroke(Color.green.opacity(0.2), lineWidth: 15)
        .frame(width: 150, height: 150)
      
      Circle()
        .trim(from: 0, to: CGFloat(result.score) / 100)
        .stroke(Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
        .frame(width: 150, height: 150)
        .rotationEffect(.degrees(-90))
        .animation(.easeInOut(duration: 1.5).delay(0.2), value: result.score)
      
      VStack {
        Text("\(result.score)")
          .font(.system(size: 48, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
        Text("Skor")
          .font(.headline)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private var summaryCardView: some View {
    VStack(spacing: 16) {
      summaryRow(label: "Durasi", value: duration)
      Divider()
      summaryRow(label: "Benar", value: "\(correctAnswers)", valueBackgroundColor: .green.opacity(0.2), valueForegroundColor: .green)
      Divider()
      summaryRow(label: "Salah", value: "\(wrongAnswers)", valueBackgroundColor: .red.opacity(0.2), valueForegroundColor: .red)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
  
  private func summaryRow(label: String, value: String, valueBackgroundColor: Color? = nil, valueForegroundColor: Color? = nil) -> some View {
    HStack {
      Text(label)
        .font(.headline)
        .foregroundColor(.secondary)
      Spacer()
      if let bgColor = valueBackgroundColor, let fgColor = valueForegroundColor {
        Text(value)
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(fgColor)
          .padding(.horizontal, 12)
          .padding(.vertical, 4)
          .background(bgColor)
          .cornerRadius(8)
      } else {
        Text(value)
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.primary)
      }
    }
  }
  
  private var actionButtonsView: some View {
    VStack(spacing: 16) {
      // Lihat Pembahasan Button
      Button(action: {
        showPembahasan = true
      }) {
        Text("Lihat pembahasan soal")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(Color.blue)
          .cornerRadius(16)
      }
      
      // Kembali ke Beranda Button
      Button(action: navigateToHome) {
        Text("Halaman beranda")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.blue)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(Color.blue.opacity(0.15))
          .cornerRadius(16)
      }
    }
  }
  
  // MARK: - Helper Methods
  
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
      paket: Paket(id: 1, name: "Try Out Appskep Part 1", description: "Test", duration: 150, totalQuestions: 4),
      soals: [],
      answers: []
    )
  )
  .environmentObject(TryOutCoordinator())
}
