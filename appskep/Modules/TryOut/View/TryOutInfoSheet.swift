//
//  TryOutInfoSheet.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct TryOutInfoSheet: View {
  let paket: Paket
  let orderId: Int
  
  @StateObject private var viewModel = TryOutViewModel()
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  @Environment(\.dismiss) private var dismiss
  
  // State for retry eligibility
  @State private var actionState: TryOutActionState = .loading
  @State private var retryData: RetryEligibilityData?
  @State private var showRetryConfirmation = false
  @State private var showResultDetail = false
  @State private var showMaxAttemptsAlert = false
  
  var body: some View {
    VStack(spacing: 20) {
      headerSection
      prosedurSection
      Divider()
      infoSection
      Spacer()
      actionSection
    }
    .padding()
    .navigationTitle("Detail Paket")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        await checkRetryEligibility()
      }
    }
    .alert("Maksimal Percobaan", isPresented: $showMaxAttemptsAlert) {
      Button("Lihat Hasil Terbaik") {
        showResultDetail = true
      }
      Button("Tutup") {
        dismiss()
      }
    } message: {
      if let bestScore = retryData?.best_score {
        Text("Anda telah mencapai maksimal percobaan (\(retryData?.total_attempts ?? 0)x). Skor terbaik Anda: \(bestScore)")
      } else {
        Text("Anda telah mencapai maksimal percobaan untuk try-out ini.")
      }
    }
    .confirmationDialog("Mulai Try Out Baru", isPresented: $showRetryConfirmation) {
      Button("Mulai Sekarang") {
        Task {
          await startTryOut()
        }
      }
      Button("Batal", role: .cancel) { }
    } message: {
      if let retryData = retryData, retryData.total_attempts > 0 {
        let scoreText = retryData.best_score ?? 0 > 0 ? "Skor terbaik: \(retryData.best_score!)" : "Belum ada skor"
        let statusText = retryData.has_passed ? "Lulus" : "Belum Lulus"
        Text("Percobaan sebelumnya: \(scoreText) (\(statusText))\n\nMulai percobaan baru?")
      } else {
        Text("Anda akan memulai percobaan baru untuk try-out ini.")
      }
    }
    .sheet(isPresented: $showResultDetail) {
      if let lastAttempt = retryData?.last_attempt {
        TryOutResultDetailSheet(
          attemptInfo: lastAttempt,
          canRetry: retryData?.can_retry ?? false,
          onRetry: {
            showResultDetail = false
            showRetryConfirmation = true
          }
        )
      }
    }
  }
  
  private var headerSection: some View {
    VStack(spacing: 8) {
      Text(paket.name)
        .font(.title2)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
      
      if let retryData = retryData {
        statusBadge(for: retryData)
      }
    }
  }
  
  @ViewBuilder
  private func statusBadge(for data: RetryEligibilityData) -> some View {
      HStack(spacing: 8) {
          // Single attempt badge
          Label("1x Percobaan", systemImage: "1.circle.fill")
              .font(.caption)
              .foregroundColor(.orange)
              .padding(.horizontal, 12)
              .padding(.vertical, 4)
              .background(Color.orange.opacity(0.1))
              .cornerRadius(16)
          
          if data.has_passed && data.total_attempts > 0 {
              Label("Lulus", systemImage: "checkmark.circle.fill")
                  .font(.caption)
                  .foregroundColor(.green)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 4)
                  .background(Color.green.opacity(0.1))
                  .cornerRadius(16)
          } else if data.total_attempts > 0 {
              Label("Selesai", systemImage: "clock.fill")
                  .font(.caption)
                  .foregroundColor(.gray)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 4)
                  .background(Color.gray.opacity(0.1))
                  .cornerRadius(16)
          }
      }
  }
  
  private var prosedurSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Prosedur Try Out")
        .font(.headline)
      Text("1. Pastikan koneksi internet stabil\n2. Klik Tombol Mulai Try Out untuk memulai\n3. Pilih jawaban dengan klik pada button jawaban yang dipilih\n4. Berpindah soal dapat dilakukan dengan klik pada tombol Sebelumnya atau Selanjutnya, atau juga bisa dengan klik nomor soal pada Overview Jawaban\n5. Jawaban yang sudah dipilih akan langsung tersimpan di sistem selagi tidak ada gangguan jaringan\n6. Timer tidak dapat dihentikan atau dijeda\n7. Jika sudah selesai mengerjakan, klik selesaikan try out\n8. **PENTING: Halaman try out akan fullscreen dan tidak dapat keluar sampai selesai**")
        .font(.caption)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private var infoSection: some View {
      VStack(alignment: .leading, spacing: 12) {
          Text("Informasi Try Out")
              .font(.headline)
          
          infoRow(label: "Waktu pengerjaan:", value: "\(paket.duration) menit")
          infoRow(label: "Jumlah soal:", value: "\(paket.totalQuestions ?? 50) Soal")
          infoRow(label: "Percobaan:", value: "1x (Hanya sekali)")
          
          if let retryData = retryData {
              // Show result if already attempted
              if retryData.total_attempts > 0 {
                  if let bestScore = retryData.best_score, bestScore > 0 {
                      infoRow(label: "Skor Anda:", value: "\(bestScore)")
                  }
                  infoRow(label: "Status:", value: retryData.has_passed ? "Lulus ✅" : "Belum Lulus ❌")
              }
          }
      }
  }
  
  @ViewBuilder
  private var actionSection: some View {
      switch actionState {
      case .loading:
          ProgressView("Mengecek status...")
              .frame(maxWidth: .infinity)
              .padding()
          
      case .canStart:
          VStack(spacing: 12) {
              // Warning for single attempt
              HStack {
                  Image(systemName: "exclamationmark.triangle.fill")
                      .foregroundColor(.orange)
                  Text("Try out hanya dapat dilakukan 1 kali")
                      .font(.caption)
                      .foregroundColor(.orange)
              }
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.orange.opacity(0.1))
              .cornerRadius(8)
              
              actionButton(
                  title: "Mulai Try Out",
                  color: .main,
                  action: {
                      showRetryConfirmation = true // Show confirmation first
                  }
              )
          }
          
      case .showResult(let syntheticAttempt):
          VStack(spacing: 12) {
              // Show result card
              resultSummaryCard(syntheticAttempt)
              
              // Info that try out is completed
              VStack(spacing: 8) {
                  HStack {
                      Image(systemName: "checkmark.circle.fill")
                          .foregroundColor(.green)
                      Text("Try out telah selesai")
                          .font(.subheadline)
                          .fontWeight(.medium)
                  }
                  
                  Text("Try out hanya dapat dilakukan sekali untuk setiap paket")
                      .font(.caption)
                      .foregroundColor(.secondary)
                      .multilineTextAlignment(.center)
              }
              .padding()
              .background(Color(.systemGray6))
              .cornerRadius(12)
          }
          
      case .maxAttemptsReached(let bestScore):
          // This shouldn't happen with single attempt, but keep for safety
          VStack(spacing: 16) {
              VStack(spacing: 8) {
                  Image(systemName: "checkmark.circle.fill")
                      .font(.title)
                      .foregroundColor(.green)
                  
                  Text("Try Out Selesai")
                      .font(.headline)
                      .multilineTextAlignment(.center)
                  
                  if bestScore > 0 {
                      Text("Skor: \(bestScore)")
                          .font(.title2)
                          .fontWeight(.bold)
                          .foregroundColor(.main)
                  }
              }
              .padding()
              .background(Color.green.opacity(0.1))
              .cornerRadius(16)
          }
          
      case .waitingRetry(_):
          // This shouldn't happen with single attempt
          VStack(spacing: 16) {
              VStack(spacing: 8) {
                  Image(systemName: "info.circle.fill")
                      .font(.title)
                      .foregroundColor(.blue)
                  
                  Text("Try Out Sudah Selesai")
                      .font(.headline)
                  
                  Text("Try out hanya dapat dilakukan sekali")
                      .font(.subheadline)
                      .foregroundColor(.secondary)
              }
              .padding()
              .background(Color.blue.opacity(0.1))
              .cornerRadius(16)
          }
          
      case .error(let message):
          VStack(spacing: 16) {
              Image(systemName: "exclamationmark.triangle.fill")
                  .font(.title)
                  .foregroundColor(.red)
              
              Text("Terjadi Kesalahan")
                  .font(.headline)
              
              Text(message)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.center)
              
              Button("Coba Lagi") {
                  Task {
                      await checkRetryEligibility()
                  }
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.main)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
      }
  }
  
  private func resultSummaryCard(_ attempt: LastAttemptInfo) -> some View {
      VStack(spacing: 16) {
          // Score Circle
          ZStack {
              Circle()
                  .stroke(Color(.systemGray5), lineWidth: 12)
                  .frame(width: 120, height: 120)
              
              Circle()
                  .trim(from: 0, to: CGFloat(attempt.score) / 100)
                  .stroke(attempt.passed ? Color.green : Color.red, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                  .frame(width: 120, height: 120)
                  .rotationEffect(.degrees(-90))
              
              VStack {
                  Text("\(attempt.score)")
                      .font(.system(size: 28, weight: .bold))
                  Text("Skor")
                      .font(.caption)
                      .foregroundColor(.secondary)
              }
          }
          
          // Status
          VStack(spacing: 8) {
              Text(attempt.passed ? "LULUS" : "BELUM LULUS")
                  .font(.headline)
                  .fontWeight(.bold)
                  .foregroundColor(attempt.passed ? .green : .red)
              
              Text("Try out telah selesai")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
          }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color(.systemGray6))
      .cornerRadius(16)
  }
  
  private func lastResultCard(_ attempt: LastAttemptInfo) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Percobaan Terakhir")
          .font(.caption)
          .foregroundColor(.secondary)
        
        HStack {
          Text("Skor: \(attempt.score)")
            .font(.headline)
            .fontWeight(.bold)
          
          Text(attempt.passed ? "Lulus" : "Belum Lulus")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(attempt.passed ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background((attempt.passed ? Color.green : Color.red).opacity(0.1))
            .cornerRadius(8)
        }
        
        Text(formatDate(attempt.finished_at))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Image(systemName: attempt.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.title2)
        .foregroundColor(attempt.passed ? .green : .red)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      if viewModel.isLoading {
        HStack {
          ProgressView()
            .scaleEffect(0.8)
          Text("Memproses...")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(color.opacity(0.6))
        .foregroundColor(.white)
        .cornerRadius(12)
      } else {
        Text(title)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(color)
          .foregroundColor(.white)
          .cornerRadius(12)
      }
    }
    .disabled(viewModel.isLoading)
  }
  
  private func infoRow(label: String, value: String) -> some View {
    HStack {
      Text(label)
      Spacer()
      Text(value).fontWeight(.bold)
    }
  }
  
  // MARK: - API Methods
  private func checkRetryEligibility() async {
    actionState = .loading
    
    do {
      let response: RetryEligibilityResponse = try await APIService.shared.performRequest(
        endpoint: .checkRetryEligibility(orderId: orderId, paketId: paket.id),
        method: .GET,
        responseType: RetryEligibilityResponse.self
      )
      
      if response.success, let data = response.data {
        retryData = data
        await MainActor.run {
          updateActionState(with: data)
        }
      } else {
        actionState = .error(response.error ?? response.message)
      }
    } catch {
      actionState = .error("Gagal mengecek status: \(error.localizedDescription)")
    }
  }
  
  private func updateActionState(with data: RetryEligibilityData) {
      // Since try out can only be done once, simplify the logic
      if data.total_attempts == 0 {
          // First time - can start
          actionState = .canStart
      } else {
          // Already attempted - show result (no retry since only 1 attempt allowed)
          let syntheticAttempt = LastAttemptInfo(
              id: data.attempt_number,
              score: data.best_score ?? 0,
              passed: data.has_passed,
              finished_at: "2024-01-01T00:00:00Z", // Placeholder since API doesn't provide
              status: "finished"
          )
          actionState = .showResult(syntheticAttempt)
      }
  }
  
  private func startTryOut() async {
    let success = await viewModel.startTryOut(orderId: orderId, paketId: paket.id)
    if success, let sessionId = viewModel.tryOutSession?.id {
      dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        tryOutCoordinator.startTryOut(tryOutId: sessionId)
      }
    } else {
      // Handle error from viewModel
      if let error = viewModel.errorMessage {
        actionState = .error(error)
      }
    }
  }
  
  // MARK: - Helper Methods
  private func formatDate(_ dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: dateString) {
      let displayFormatter = DateFormatter()
      displayFormatter.dateStyle = .medium
      displayFormatter.timeStyle = .short
      return displayFormatter.string(from: date)
    }
    return dateString
  }
  
  private func formatDateFromDate(_ date: Date) -> String {
    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .medium
    displayFormatter.timeStyle = .short
    return displayFormatter.string(from: date)
  }
  
  private func parseDate(_ dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: dateString)
  }
}

// MARK: - Result Detail Sheet
struct TryOutResultDetailSheet: View {
  let attemptInfo: LastAttemptInfo
  let canRetry: Bool
  let onRetry: () -> Void
  
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        // Score Circle
        ZStack {
          Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            .frame(width: 150, height: 150)
          
          Circle()
            .trim(from: 0, to: CGFloat(attemptInfo.score) / 100)
            .stroke(attemptInfo.passed ? Color.green : Color.red, style: StrokeStyle(lineWidth: 12, lineCap: .round))
            .frame(width: 150, height: 150)
            .rotationEffect(.degrees(-90))
          
          VStack {
            Text("\(attemptInfo.score)")
              .font(.system(size: 36, weight: .bold))
            Text("Skor")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
        
        // Status
        VStack(spacing: 8) {
          Text(attemptInfo.passed ? "LULUS" : "BELUM LULUS")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(attemptInfo.passed ? .green : .red)
          
          Text("Selesai pada \(formatDate(attemptInfo.finished_at))")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        // Action Buttons
        VStack(spacing: 12) {
          if canRetry {
            Button("Coba Lagi") {
              dismiss()
              onRetry()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.main)
            .foregroundColor(.white)
            .cornerRadius(12)
            .fontWeight(.semibold)
          }
          
          Button("Tutup") {
            dismiss()
          }
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color(.systemGray5))
          .foregroundColor(.primary)
          .cornerRadius(12)
        }
      }
      .padding()
      .navigationTitle("Detail Hasil")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Tutup") { dismiss() }
        }
      }
    }
  }
  
  private func formatDate(_ dateString: String) -> String {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: dateString) {
      let displayFormatter = DateFormatter()
      displayFormatter.dateStyle = .long
      displayFormatter.timeStyle = .short
      return displayFormatter.string(from: date)
    }
    return dateString
  }
}

#Preview {
  TryOutInfoSheet(
    paket: Paket(id: 1, name: "Try Out Komprehensif UKOM Updated", description: "Paket soal komprehensif yang telah diperbarui", duration: 150, totalQuestions: 5),
    orderId: 1
  )
}
