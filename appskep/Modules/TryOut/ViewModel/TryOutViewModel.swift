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
    
    // MARK: - Private State
    private var selectedAnswers: [Int: Int] = [:] // [soalId: pilihanJawabanId]
    private var timeRemainingInSeconds: Int = 0
    private var timer: AnyCancellable?

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

    // MARK: - Public Methods (Actions from View)
    
    func startTryOut(orderId: Int, paketId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let request = StartTryOutRequest(order_id: orderId, paket_id: paketId)
        
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
                self.errorMessage = response.message
                isLoading = false
                return false
            }
        } catch {
            self.errorMessage = error.localizedDescription
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
        selectedAnswers[currentSoalId] = optionId
        // Force UI update for the selected option
        objectWillChange.send()
    }
    
    func isSelected(option: PilihanJawaban) -> Bool {
        guard let currentSoalId = currentSoal?.id else { return false }
        return selectedAnswers[currentSoalId] == option.id
    }
    
    func finishTryOut() {
        // TODO: Implement API call to submit answers
        print("Try Out Finished. Answers: \(selectedAnswers)")
        stopTimer()
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
            finishTryOut()
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
