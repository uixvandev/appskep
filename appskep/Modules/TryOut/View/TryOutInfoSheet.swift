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
    @State private var actualTryOutId: Int?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Quick Info Cards
                    quickInfoGrid
                    
                    // Procedure Card
                    procedureCard
                    
                    // Results Card (if available)
                    if let retryData = retryData, retryData.total_attempts > 0 {
                        resultsCard
                    }
                }
                .padding()
                .padding(.bottom, getBottomPadding()) // Dynamic padding based on action state
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                actionSection
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 34) // Safe area padding
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .navigationTitle("Detail Try Out")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Kembali")
                    }
                    .foregroundColor(.main)
                }
            }
        }
        .onAppear {
            Task { await checkRetryEligibility() }
        }
        .alert("Maksimal Percobaan", isPresented: $showMaxAttemptsAlert) {
            Button("Lihat Hasil Terbaik") { showResultDetail = true }
            Button("Tutup") { dismiss() }
        } message: {
            Text("Anda telah mencapai batas maksimal percobaan untuk paket ini.")
        }
        .confirmationDialog("Konfirmasi Mulai", isPresented: $showRetryConfirmation, titleVisibility: .visible) {
            Button("Mulai Sekarang", role: .destructive) {
                Task { await startTryOut() }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Try out hanya dapat dilakukan sekali. Pastikan Anda siap karena waktu akan langsung berjalan dan tidak bisa dijeda.")
        }
        .sheet(isPresented: $showResultDetail) {
            if let tryOutId = actualTryOutId {
                TryOutResultDetailSheet(
                    attempt: createLastAttemptInfo() ?? LastAttemptInfo(id: 0, score: 0, passed: false, finished_at: "", status: ""),
                    actualTryOutId: tryOutId
                )
            }
        }
    }
    
    // MARK: - Helper Methods for Layout
    
    /// Calculate dynamic bottom padding based on action state
    private func getBottomPadding() -> CGFloat {
        switch actionState {
        case .loading:
            return 120 // Compact loading state
        case .canStart:
            return 180 // Warning card + action button
        case .showResult:
            return 200 // Success card + action button
        case .maxAttemptsReached, .waitingRetry:
            return 160 // Single card
        case .error:
            return 180 // Error card + retry button
        }
    }
    
    // MARK: - UI Components (existing code remains the same)
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.main.opacity(0.8), Color.main]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            
            // Title and badges
            VStack(spacing: 12) {
                Text(paket.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                if let retryData = retryData {
                    statusBadgesRow(for: retryData)
                }
            }
        }
        .padding(.vertical)
    }
    
    private var quickInfoGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            QuickInfoCard(
                icon: "clock.fill",
                title: "Durasi",
                value: "\(paket.duration)",
                subtitle: "menit",
                color: .blue
            )
            
            QuickInfoCard(
                icon: "questionmark.circle.fill",
                title: "Soal",
                value: "\(paket.totalQuestions ?? 50)",
                subtitle: "pertanyaan",
                color: .green
            )
            
            QuickInfoCard(
                icon: "arrow.clockwise",
                title: "Kesempatan",
                value: "1x",
                subtitle: "percobaan",
                color: .orange
            )
        }
    }
    
    private var procedureCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .font(.title2)
                    .foregroundColor(.main)
                
                Text("Aturan & Prosedur")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            // Rules list
            VStack(alignment: .leading, spacing: 12) {
                ProcedureRow(
                    icon: "wifi",
                    text: "Pastikan koneksi internet stabil",
                    iconColor: .blue
                )
                
                ProcedureRow(
                    icon: "play.circle.fill",
                    text: "Timer dimulai otomatis dan tidak dapat dijeda",
                    iconColor: .orange
                )
                
                ProcedureRow(
                    icon: "checkmark.shield.fill",
                    text: "Jawaban tersimpan otomatis setiap kali dipilih",
                    iconColor: .green
                )
                
                ProcedureRow(
                    icon: "exclamationmark.triangle.fill",
                    text: "Mode fullscreen - tidak dapat keluar hingga selesai",
                    iconColor: .red
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.title2)
                    .foregroundColor(.main)
                
                Text("Hasil Anda")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let retryData = retryData {
                HStack(spacing: 20) {
                    // Score display
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 8)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(retryData.best_score ?? 0) / 100)
                                .stroke(
                                    retryData.has_passed ? Color.green : Color.red,
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(retryData.best_score ?? 0)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Text("Skor")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Status
                        HStack {
                            Image(systemName: retryData.has_passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(retryData.has_passed ? .green : .red)
                            
                            Text(retryData.has_passed ? "LULUS" : "BELUM LULUS")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(retryData.has_passed ? .green : .red)
                        }
                        
                        // Info
                        Text("Try out telah selesai dikerjakan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // View details button
                        Button(action: { showResultDetail = true }) {
                            Text("Lihat Detail")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.main)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func statusBadgesRow(for data: RetryEligibilityData) -> some View {
        HStack(spacing: 8) {
            StatusBadge(
                icon: "1.circle.fill",
                text: "Sekali Coba",
                color: .orange
            )
            
            if data.total_attempts > 0 {
                StatusBadge(
                    icon: data.has_passed ? "checkmark.circle.fill" : "clock.fill",
                    text: data.has_passed ? "Lulus" : "Selesai",
                    color: data.has_passed ? .green : .gray
                )
            }
        }
    }
    
    @ViewBuilder
    private var actionSection: some View {
        switch actionState {
        case .loading:
            VStack(spacing: 8) { // Reduced spacing for compact loading
                ProgressView()
                    .scaleEffect(1.2)
                Text("Memuat status...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16) // Reduced padding
            
        case .canStart:
            VStack(spacing: 12) { // Reduced spacing
                // Compact Warning
                HStack(spacing: 8) { // Horizontal layout for compact warning
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.callout)
                        .foregroundColor(.orange)
                    
                    Text("Try out hanya dapat dilakukan sekali. Pastikan Anda siap!")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12) // Reduced padding
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                // Action button
                ActionButton(
                    title: "Mulai Try Out",
                    subtitle: "Siap untuk memulai?",
                    icon: "play.fill",
                    color: .main,
                    isLoading: viewModel.isLoading
                ) {
                    showRetryConfirmation = true
                }
            }
            
        case .showResult:
            VStack(spacing: 12) {
                if let retryData = retryData {
                    // Compact success card
                    HStack(spacing: 12) {
                        Image(systemName: retryData.has_passed ? "checkmark.circle.fill" : "clock.fill")
                            .font(.title2)
                            .foregroundColor(retryData.has_passed ? .green : .blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Try Out Selesai")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(retryData.has_passed ? "Selamat! Anda telah lulus." : "Try out telah diselesaikan.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background((retryData.has_passed ? Color.green : Color.blue).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    ActionButton(
                        title: "Lihat Hasil Detail",
                        subtitle: "Skor: \(retryData.best_score ?? 0)",
                        icon: "chart.bar.fill",
                        color: .blue,
                        isLoading: false
                    ) {
                        showResultDetail = true
                    }
                }
            }
            
        case .maxAttemptsReached(let bestScore):
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Try Out Selesai")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Skor terbaik: \(bestScore)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
        case .waitingRetry:
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Try Out Selesai")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Try out hanya dapat dilakukan sekali")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
        case .error(let message):
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terjadi Kesalahan")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                ActionButton(
                    title: "Coba Lagi",
                    subtitle: "Muat ulang status",
                    icon: "arrow.clockwise",
                    color: .main,
                    isLoading: false
                ) {
                    Task { await checkRetryEligibility() }
                }
            }
        }
    }
    
    // ... rest of the existing code remains the same ...
    
    // MARK: - Helper Methods
    
    private func createLastAttemptInfo() -> LastAttemptInfo? {
        guard let retryData = retryData, retryData.total_attempts > 0 else { return nil }
        
        return LastAttemptInfo(
            id: retryData.attempt_number,
            score: retryData.best_score ?? 0,
            passed: retryData.has_passed,
            finished_at: "2024-01-01T00:00:00Z",
            status: "finished"
        )
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
                
                // If the user has completed tries, get the actual try-out ID
                if data.total_attempts > 0 {
                    await fetchActualTryOutId()
                }
                
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
    
    private func fetchActualTryOutId() async {
        do {
            let response: TryOutHistoryResponse = try await APIService.shared.performRequest(
                endpoint: .getTryOutHistory(page: 1, limit: 10),
                method: .GET,
                responseType: TryOutHistoryResponse.self
            )
            
            if response.success {
                // Find the try-out for this paket that is completed
                let completedTryOut = response.data.data.first { historyItem in
                    historyItem.paket_id == paket.id && historyItem.finished_at != nil
                }
                
                if let tryOut = completedTryOut {
                    actualTryOutId = tryOut.id
                    print("✅ Found actual try-out ID: \(tryOut.id) for paket: \(paket.id)")
                }
            }
        } catch {
            print("❌ Failed to fetch try-out history: \(error)")
        }
    }
    
    private func updateActionState(with data: RetryEligibilityData) {
        if data.total_attempts == 0 {
            actionState = .canStart
        } else {
            let syntheticAttempt = LastAttemptInfo(
                id: data.attempt_number,
                score: data.best_score ?? 0,
                passed: data.has_passed,
                finished_at: "2024-01-01T00:00:00Z",
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
            if let error = viewModel.errorMessage {
                actionState = .error(error)
            }
        }
    }
    
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
}

// MARK: - Reusable Components (Only UI Components, no type definitions)

struct QuickInfoCard: View {
  let icon: String
  let title: String
  let value: String
  let subtitle: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(color)
      
      VStack(spacing: 2) {
        Text(value)
          .font(.headline)
          .fontWeight(.bold)
        
        Text(title)
          .font(.caption2)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
        
        Text(subtitle)
          .font(.caption2)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

struct ProcedureRow: View {
  let icon: String
  let text: String
  let iconColor: Color
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.callout)
        .foregroundColor(iconColor)
        .frame(width: 20)
        .padding(.top, 2)
      
      Text(text)
        .font(.subheadline)
        .foregroundColor(.primary)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

struct StatusBadge: View {
  let icon: String
  let text: String
  let color: Color
  
  var body: some View {
    Label(text, systemImage: icon)
      .font(.caption)
      .fontWeight(.medium)
      .foregroundColor(color)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(color.opacity(0.15))
      .clipShape(Capsule())
  }
}

struct ActionButton: View {
  let title: String
  let subtitle: String?
  let icon: String
  let color: Color
  let isLoading: Bool
  let action: () -> Void
  
  init(title: String, subtitle: String? = nil, icon: String, color: Color, isLoading: Bool, action: @escaping () -> Void) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.color = color
    self.isLoading = isLoading
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if isLoading {
          ProgressView()
            .scaleEffect(0.9)
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: icon)
            .font(.title3)
        }
        
        VStack(alignment: .leading, spacing: 2) {
          Text(isLoading ? "Memproses..." : title)
            .font(.headline)
            .fontWeight(.semibold)
          
          if let subtitle = subtitle, !isLoading {
            Text(subtitle)
              .font(.caption)
              .opacity(0.8)
          }
        }
        
        Spacer()
      }
      .foregroundColor(.white)
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity)
      .background(
        LinearGradient(
          gradient: Gradient(colors: [color, color.opacity(0.8)]),
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    .disabled(isLoading)
    .scaleEffect(isLoading ? 0.98 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: isLoading)
  }
}

struct WarningCard: View {
  let icon: String
  let message: String
  let color: Color
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title3)
        .foregroundColor(color)
      
      Text(message)
        .font(.subheadline)
        .foregroundColor(.primary)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(16)
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}

struct SuccessCard: View {
  let icon: String
  let title: String
  let message: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 32))
        .foregroundColor(color)
      
      VStack(spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.bold)
        
        Text(message)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity)
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

struct InfoCard: View {
  let icon: String
  let title: String
  let message: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 32))
        .foregroundColor(color)
      
      VStack(spacing: 4) {
        Text(title)
          .font(.headline)
          .fontWeight(.bold)
        
        Text(message)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity)
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

struct ErrorCard: View {
  let message: String
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 32))
        .foregroundColor(.red)
      
      VStack(spacing: 4) {
        Text("Terjadi Kesalahan")
          .font(.headline)
          .fontWeight(.bold)
        
        Text(message)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity)
    .background(Color.red.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

// MARK: - Result Detail Sheet
struct TryOutResultDetailSheet: View {
    let attempt: LastAttemptInfo
    let actualTryOutId: Int  // Add this parameter
    @Environment(\.dismiss) private var dismiss
    
    // Mock data for consistency - in real app, you'd pass actual result data
    private var mockTotalQuestions: Int { 50 }
    private var mockCorrectAnswers: Int {
        Int(Double(attempt.score) / 100.0 * Double(mockTotalQuestions))
    }
    private var mockWrongAnswers: Int {
        mockTotalQuestions - mockCorrectAnswers
    }
    private var mockDuration: String { "45 Menit" }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient (same as TryOutResultView)
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Top Illustration (same as TryOutResultView)
                        Image(systemName: "rosette")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                            .padding(.top, 40)
                        
                        // Title (same as TryOutResultView)
                        Text("Selamat!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Subtitle
                        Text("Kamu telah menyelesaikan try out")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Score Circle (same design as TryOutResultView)
                        scoreCircleView
                            .padding(.vertical, 20)
                        
                        // Summary Card (same design as TryOutResultView)
                        summaryCardView
                        
                        // Action Buttons (same design as TryOutResultView)
                        actionButtonsView
                            .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Hasil Try Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                        .foregroundColor(.main)
                }
            }
        }
    }
    
    // MARK: - UI Components (matching TryOutResultView exactly)
    
    private var scoreCircleView: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.2), lineWidth: 15)
                .frame(width: 150, height: 150)
            
            Circle()
                .trim(from: 0, to: CGFloat(attempt.score) / 100)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5).delay(0.2), value: attempt.score)
            
            VStack {
                Text("\(attempt.score)")
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
            summaryRow(label: "Durasi", value: mockDuration)
            Divider()
            summaryRow(
                label: "Benar",
                value: "\(mockCorrectAnswers)",
                valueBackgroundColor: .green.opacity(0.2),
                valueForegroundColor: .green
            )
            Divider()
            summaryRow(
                label: "Salah",
                value: "\(mockWrongAnswers)",
                valueBackgroundColor: .red.opacity(0.2),
                valueForegroundColor: .red
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func summaryRow(
        label: String,
        value: String,
        valueBackgroundColor: Color? = nil,
        valueForegroundColor: Color? = nil
    ) -> some View {
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
            // Lihat Pembahasan Button - Use actualTryOutId instead of attempt.id
            NavigationLink(destination: PembahasanView(tryOutId: actualTryOutId)) {
                Text("Lihat pembahasan soal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            
            // Tutup Button (instead of "Halaman beranda")
            Button(action: { dismiss() }) {
                Text("Tutup")
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
}

#Preview {
  NavigationStack {
    TryOutInfoSheet(
      paket: Paket(id: 1, name: "Try Out Komprehensif UKOM Updated", description: "Paket soal komprehensif yang telah diperbarui", duration: 150, totalQuestions: 180),
      orderId: 1
    )
    .environmentObject(TryOutCoordinator())
  }
}
