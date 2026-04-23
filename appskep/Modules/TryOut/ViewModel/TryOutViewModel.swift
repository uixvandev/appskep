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
  private var _selectedAnswers: [String: Int] = [:] // [questionCode: optionsId]
  private var doubtAnswers: Set<String> = [] // Set of question codes marked as doubt
  private var timeRemainingInSeconds: Int = 0
  private var timer: AnyCancellable?
  
  // MARK: - Coordinator injection (Pure SwiftUI)
  private weak var coordinator: TryOutCoordinator?
  
  func setCoordinator(_ coordinator: TryOutCoordinator) {
    self.coordinator = coordinator
  }
  
  // MARK: - Public computed properties for UI access
  var selectedAnswers: [String: Int] {
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

  var doubtQuestionCodes: Set<String> {
    doubtAnswers
  }

  var isCurrentSoalAnswered: Bool {
    guard let currentQuestionCode = currentSoal?.question_code else { return false }
    return _selectedAnswers[currentQuestionCode] != nil
  }
  
  // MARK: - Public Methods (Actions from View)
    func startTryOut(orderNumber: String, packageCode: String) async -> Bool {
      isLoading = true
      errorMessage = nil
      
        let request = StartTryOutRequest(order_number: orderNumber, package_code: packageCode)
      
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
  
  func fetchTryOutDetail(tryoutCode: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
      let response: TryOutDetailResponse = try await APIService.shared.performRequest(
        endpoint: .getTryOutDetail(tryoutCode: tryoutCode),
        method: .GET,
        responseType: TryOutDetailResponse.self
      )
      
      if response.success {
        self.tryOutDetail = response.data
        self.timeRemainingInSeconds = (response.data.paket.duration * 60)
        
        // Create tryOutSession from tryOutDetail if it doesn't exist
        if self.tryOutSession == nil {
          let packageCode: String = response.data.package_code ?? ""
          self.tryOutSession = TryOutSessionData(
            tryout_code: response.data.tryout_code,
            order_number: "", // We don't have this from detail response
            package_code: packageCode,
            started_at: "", // We don't have this from detail response
            status: "started",
            paket_name: response.data.paket.name
          )
          print("✅ TryOut session created from detail with code: \(response.data.tryout_code)")
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
    guard let currentQuestionCode = currentSoal?.question_code else { return }
    _selectedAnswers[currentQuestionCode] = optionId
    print("📝 Answer selected for soal \(currentQuestionCode): option \(optionId)")
    // Force UI update for the selected option
    objectWillChange.send()
  }
  
  func toggleDoubt() {
    guard let currentQuestionCode = currentSoal?.question_code else { return }
    if doubtAnswers.contains(currentQuestionCode) {
      doubtAnswers.remove(currentQuestionCode)
      print("🚩 Removed doubt flag for soal \(currentQuestionCode)")
    } else {
      doubtAnswers.insert(currentQuestionCode)
      print("🚩 Added doubt flag for soal \(currentQuestionCode)")
    }
    objectWillChange.send()
  }
  
  func isSelected(option: PilihanJawaban) -> Bool {
    guard let currentQuestionCode = currentSoal?.question_code else { return false }
    return _selectedAnswers[currentQuestionCode] == option.options_id
  }
  
  func isCurrentSoalMarkedAsDoubt() -> Bool {
    guard let currentQuestionCode = currentSoal?.question_code else { return false }
    return doubtAnswers.contains(currentQuestionCode)
  }
  
  func showFinishTryOutConfirmation() {
    showFinishConfirmation = true
  }
  
  func finishTryOut(isAutoSubmit: Bool = false) async {
    // Try to get tryoutCode from multiple sources
    let tryoutCode: String
    
    if let sessionCode = tryOutSession?.tryout_code {
      tryoutCode = sessionCode
      print("🎯 Using tryoutCode from session: \(tryoutCode)")
    } else if let detailCode = tryOutDetail?.tryout_code {
      tryoutCode = detailCode
      print("🎯 Using tryoutCode from detail: \(tryoutCode)")
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
    
    print("🚀 Starting finish try out process for code: \(tryoutCode)")
    print("📊 Current answers: \(_selectedAnswers)")
    print("🚩 Current doubts: \(doubtAnswers)")
    
    isSubmitting = true
    stopTimer()
    
    // Step 1: Submit all answers
    print("📝 Step 1: Submitting all answers...")
    let submitSuccess = await submitAllAnswers(tryoutCode: tryoutCode)
    
    if submitSuccess {
      print("✅ Step 1 successful. Proceeding to finish try out...")
      // Step 2: Finish try out
      await finishTryOutSession(tryoutCode: tryoutCode)
    } else {
      print("❌ Step 1 failed. Cannot proceed to finish try out.")
    }
    
    isSubmitting = false
  }
  
  // MARK: - Private Methods
  
  private func submitAllAnswers(tryoutCode: String) async -> Bool {
    guard let soals = tryOutDetail?.soals else {
      errorMessage = "No questions found"
      print("❌ Error: No questions found")
      return false
    }
    
    // Create answers array from selectedAnswers
    let answers: [AnswerSubmission] = soals.compactMap { soal in
      guard let selectedOptionId = _selectedAnswers[soal.question_code] else {
        print("⚠️ Skipping unanswered question: \(soal.question_code)")
        return nil // Skip unanswered questions
      }
      
      let submission = AnswerSubmission(
        question_code: soal.question_code,
        options_id: selectedOptionId,
        is_doubt: doubtAnswers.contains(soal.question_code)
      )
      
      print("📋 Including answer: question_code=\(soal.question_code), option_id=\(selectedOptionId), is_doubt=\(doubtAnswers.contains(soal.question_code))")
      return submission
    }
    
    print("📊 Submitting \(answers.count) answers out of \(soals.count) questions")
    
    let request = SubmitAllAnswersRequest(tryout_code: tryoutCode, answers: answers)
    
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
        let message = response.error ?? response.message
        if message.contains("already finished") {
          print("⚠️ Try out already finished on server. Proceeding to results.")
          return true
        }
        self.errorMessage = message
        print("❌ Submit All Answers Error: \(message)")
        return false
      }
    } catch {
      self.errorMessage = error.localizedDescription
      print("❌ Submit All Answers Exception: \(error.localizedDescription)")
      return false
    }
  }
  
  private func finishTryOutSession(tryoutCode: String) async {
    let request = FinishTryOutRequest(tryout_code: tryoutCode)
    
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
