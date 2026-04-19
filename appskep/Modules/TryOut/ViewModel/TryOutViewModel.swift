import Foundation
import Combine

@MainActor
class TryOutViewModel: ObservableObject {
  // MARK: - Published Properties (for UI)
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var tryOutDetail: TryOutDetail?
  @Published var tryOutSession: TryOutSessionData?
  
  @Published var currentSoalIndex = 0
  @Published var timeRemainingFormatted = "00 menit 00 detik"
  @Published var showOverview = false
  @Published var isSubmitting = false
  @Published var showFinishConfirmation = false
  
  // MARK: - Private State
  private var _selectedAnswers: [Int: Int] = [:] // [soalId: pilihanJawabanId]
  private var doubtAnswers: Set<Int> = [] // Set of soal IDs marked as doubt
  private var timeRemainingInSeconds: Int = 0
  private var timer: AnyCancellable?
  
  // MARK: - Coordinator injection (Pure SwiftUI)
  private weak var coordinator: TryOutCoordinator?
  
  func setCoordinator(_ coordinator: TryOutCoordinator) {
    self.coordinator = coordinator
  }
  
  // MARK: - Public computed properties for UI access
  var selectedAnswers: [Int: Int] {
    return _selectedAnswers
  }
  
  // MARK: - Computed Properties (for UI Logic)
  var currentSoal: Soal? {
    guard let soals = tryOutDetail?.soals, !soals.isEmpty, soals.indices.contains(currentSoalIndex) else {
      return nil
    }
    return soals[currentSoalIndex]
  }
  
  var progressText: String {
    let total = tryOutDetail?.soals.count ?? 0
    return "Soal \(currentSoalIndex + 1) dari \(total)"
  }
  
  var canGoToPrevious: Bool {
    currentSoalIndex > 0
  }
  
  var isLastSoal: Bool {
    guard let total = tryOutDetail?.soals.count else { return true }
    return currentSoalIndex == total - 1
  }
  
  var answeredQuestionsCount: Int {
    _selectedAnswers.count
  }
  
  var totalQuestionsCount: Int {
    tryOutDetail?.soals.count ?? 0
  }
  
  var canFinishTryOut: Bool {
    answeredQuestionsCount == totalQuestionsCount && totalQuestionsCount > 0
  }

  var hasDoubtAnswers: Bool {
    !doubtAnswers.isEmpty
  }

  var doubtSoalIds: Set<Int> {
    doubtAnswers
  }

  var isCurrentSoalAnswered: Bool {
    guard let currentSoalId = currentSoal?.id else { return false }
    return _selectedAnswers[currentSoalId] != nil
  }
  
  // MARK: - Public Methods (Actions from View)
    func startTryOut(orderId: Int, kelasPaketId: Int) async -> Bool {
      isLoading = true
      errorMessage = nil
      
        let request = StartTryOutRequest(order_id: orderId, kelas_paket_id: kelasPaketId)
      
      do {
          let bodyData = try JSONEncoder().encode(request)
          let response: StartTryOutResponse = try await APIService.shared.performRequest(
              endpoint: .startTryOut,
              method: .POST,
              body: bodyData,
              responseType: StartTryOutResponse.self
          )
          
          if response.success, let sessionData = response.data {
              self.tryOutSession = sessionData
              isLoading = false
              return true
          } else {
              // Enhanced error handling
              let message = response.error ?? response.message
              if message.contains("already finished") {
                  errorMessage = "Try-out sudah selesai. Silakan cek hasil atau coba retry jika diizinkan."
              } else if message.contains("max attempts") {
                  errorMessage = "Anda telah mencapai maksimal percobaan untuk try-out ini."
              } else if message.contains("in progress") {
                  errorMessage = "Try-out sedang berlangsung. Lanjutkan sesi yang ada."
              } else {
                  errorMessage = message
              }
              isLoading = false
              return false
          }
      } catch {
          errorMessage = "Gagal memulai try-out: \(error.localizedDescription)"
          isLoading = false
          return false
      }
  }
  
  func fetchTryOutDetail(tryOutId: Int) async {
    isLoading = true
    errorMessage = nil
    
    do {
      let response: TryOutDetailResponse = try await APIService.shared.performRequest(
        endpoint: .getTryOutDetail(id: tryOutId),
        method: .GET,
        responseType: TryOutDetailResponse.self
      )
      
      if response.success {
        self.tryOutDetail = response.data
        self.timeRemainingInSeconds = (response.data.paket.duration * 60)
        
        // Create tryOutSession from tryOutDetail if it doesn't exist
        if self.tryOutSession == nil {
          let kelasPaketId = response.data.kelas_paket_id ?? response.data.paket.id
          self.tryOutSession = TryOutSessionData(
            id: response.data.id,
            order_id: 0, // We don't have this from detail response
            kelas_paket_id: kelasPaketId,
            paket_id: response.data.paket.id,
            started_at: "", // We don't have this from detail response
            status: "started",
            paket_name: response.data.paket.name
          )
          print("✅ TryOut session created from detail with ID: \(response.data.id)")
        }
        
        startTimer()
      } else {
        self.errorMessage = response.message
      }
    } catch {
      self.errorMessage = error.localizedDescription
    }
    isLoading = false
  }
  
  func goToNextSoal() {
    guard let total = tryOutDetail?.soals.count, currentSoalIndex < total - 1 else { return }
    currentSoalIndex += 1
  }
  
  func goToPreviousSoal() {
    guard currentSoalIndex > 0 else { return }
    currentSoalIndex -= 1
  }
  
  func goToSoal(at index: Int) {
    guard let total = tryOutDetail?.soals.count, index >= 0, index < total else { return }
    currentSoalIndex = index
    showOverview = false
  }
  
  func selectAnswer(optionId: Int) {
    guard let currentSoalId = currentSoal?.id else { return }
    _selectedAnswers[currentSoalId] = optionId
    print("📝 Answer selected for soal \(currentSoalId): option \(optionId)")
    // Force UI update for the selected option
    objectWillChange.send()
  }
  
  func toggleDoubt() {
    guard let currentSoalId = currentSoal?.id else { return }
    if doubtAnswers.contains(currentSoalId) {
      doubtAnswers.remove(currentSoalId)
      print("🚩 Removed doubt flag for soal \(currentSoalId)")
    } else {
      doubtAnswers.insert(currentSoalId)
      print("🚩 Added doubt flag for soal \(currentSoalId)")
    }
    objectWillChange.send()
  }
  
  func isSelected(option: PilihanJawaban) -> Bool {
    guard let currentSoalId = currentSoal?.id else { return false }
    return _selectedAnswers[currentSoalId] == option.id
  }
  
  func isCurrentSoalMarkedAsDoubt() -> Bool {
    guard let currentSoalId = currentSoal?.id else { return false }
    return doubtAnswers.contains(currentSoalId)
  }
  
  func showFinishTryOutConfirmation() {
    showFinishConfirmation = true
  }
  
  func finishTryOut(isAutoSubmit: Bool = false) async {
    // Try to get tryOutId from multiple sources
    let tryOutId: Int
    
    if let sessionId = tryOutSession?.id {
      tryOutId = sessionId
      print("🎯 Using tryOutId from session: \(tryOutId)")
    } else if let detailId = tryOutDetail?.id {
      tryOutId = detailId
      print("🎯 Using tryOutId from detail: \(tryOutId)")
    } else {
      errorMessage = "Try out session not found"
      print("❌ Error: Try out session not found - both session and detail are nil")
      return
    }
    
    // Validasi: Pastikan semua soal sudah dijawab sebelum submit
    // Skip validation if this is an auto-submission (timer expired)
    if !isAutoSubmit && answeredQuestionsCount < totalQuestionsCount {
      errorMessage = "Harap jawab semua soal sebelum menyelesaikan try out."
      showFinishConfirmation = false
      return
    }

    if !isAutoSubmit && !doubtAnswers.isEmpty {
      errorMessage = "Masih ada soal yang ditandai ragu. Hapus tanda ragu sebelum menyelesaikan try out."
      showFinishConfirmation = false
      return
    }
    
    print("🚀 Starting finish try out process for ID: \(tryOutId)")
    print("📊 Current answers: \(_selectedAnswers)")
    print("🚩 Current doubts: \(doubtAnswers)")
    
    isSubmitting = true
    stopTimer()
    
    // Step 1: Submit all answers
    print("📝 Step 1: Submitting all answers...")
    let submitSuccess = await submitAllAnswers(tryOutId: tryOutId)
    
    if submitSuccess {
      print("✅ Step 1 successful. Proceeding to finish try out...")
      // Step 2: Finish try out
      await finishTryOutSession(tryOutId: tryOutId)
    } else {
      print("❌ Step 1 failed. Cannot proceed to finish try out.")
    }
    
    isSubmitting = false
  }
  
  // MARK: - Private Methods
  
  private func submitAllAnswers(tryOutId: Int) async -> Bool {
    guard let soals = tryOutDetail?.soals else {
      errorMessage = "No questions found"
      print("❌ Error: No questions found")
      return false
    }
    
    // Create answers array from selectedAnswers
    let answers: [AnswerSubmission] = soals.compactMap { soal in
      guard let selectedOptionId = _selectedAnswers[soal.id] else {
        print("⚠️ Skipping unanswered question: \(soal.id)")
        return nil // Skip unanswered questions
      }
      
      let submission = AnswerSubmission(
        soal_id: soal.id,
        pilihan_jawaban_id: selectedOptionId,
        is_doubt: doubtAnswers.contains(soal.id)
      )
      
      print("📋 Including answer: soal_id=\(soal.id), option_id=\(selectedOptionId), is_doubt=\(doubtAnswers.contains(soal.id))")
      return submission
    }
    
    print("📊 Submitting \(answers.count) answers out of \(soals.count) questions")
    
    let request = SubmitAllAnswersRequest(try_out_id: tryOutId, answers: answers)
    
    do {
      let bodyData = try JSONEncoder().encode(request)
      
      // Log request body for debugging
      if let jsonString = String(data: bodyData, encoding: .utf8) {
        print("📤 Submit All Answers Request Body: \(jsonString)")
      }
      
      let response: SubmitAllAnswersResponse = try await APIService.shared.performRequest(
        endpoint: .submitAllAnswers,
        method: .POST,
        body: bodyData,
        responseType: SubmitAllAnswersResponse.self
      )
      
      print("📥 Submit All Answers Response: success=\(response.success), message=\(response.message)")
      
      if response.success {
        print("✅ All answers submitted successfully")
        return true
      } else {
        self.errorMessage = response.error ?? response.message
        print("❌ Submit All Answers Error: \(response.error ?? response.message)")
        return false
      }
    } catch {
      self.errorMessage = error.localizedDescription
      print("❌ Submit All Answers Exception: \(error.localizedDescription)")
      return false
    }
  }
  
  private func finishTryOutSession(tryOutId: Int) async {
    let request = FinishTryOutRequest(try_out_id: tryOutId)
    
    do {
      let bodyData = try JSONEncoder().encode(request)
      
      // Log request body for debugging
      if let jsonString = String(data: bodyData, encoding: .utf8) {
        print("📤 Finish Try Out Request Body: \(jsonString)")
      }
      
      let response: FinishTryOutResponse = try await APIService.shared.performRequest(
        endpoint: .finishTryOut,
        method: .POST,
        body: bodyData,
        responseType: FinishTryOutResponse.self
      )
      
      print("📥 Finish Try Out Response: success=\(response.success), message=\(response.message)")
      
      if response.success {
        print("✅ Try out finished successfully!")
        if let result = response.data {
          print("📊 Final Score: \(result.score)")
          // ✅ Use SwiftUI coordinator injection instead of UIKit
          coordinator?.showResult(result)
        }
      } else {
        self.errorMessage = response.error ?? response.message
        print("❌ Finish Try Out Error: \(response.error ?? response.message)")
      }
    } catch {
      self.errorMessage = error.localizedDescription
      print("❌ Finish Try Out Exception: \(error.localizedDescription)")
    }
  }
  
  // MARK: - Timer Management
  private func startTimer() {
    stopTimer() // Ensure no multiple timers are running
    timer = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.tick()
      }
  }
  
  private func stopTimer() {
    timer?.cancel()
    timer = nil
  }
  
  private func tick() {
    guard timeRemainingInSeconds > 0 else {
      print("⏰ Time's up! Auto-finishing try out...")
      Task {
        await finishTryOut(isAutoSubmit: true)
      }
      return
    }
    timeRemainingInSeconds -= 1
    updateFormattedTime()
  }
  
  private func updateFormattedTime() {
    let minutes = timeRemainingInSeconds / 60
    let seconds = timeRemainingInSeconds % 60
    timeRemainingFormatted = String(format: "%02d menit %02d detik", minutes, seconds)
  }
}
