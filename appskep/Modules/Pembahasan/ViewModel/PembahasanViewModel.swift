//
//  PembahasanViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import Foundation

@MainActor
class PembahasanViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pembahasanData: PembahasanData?
    @Published var resultsData: TryOutResultsData?
    @Published var currentQuestionIndex = 0
    
    var currentQuestion: PembahasanQuestion? {
        guard let questions = pembahasanData?.questions,
              !questions.isEmpty,
              questions.indices.contains(currentQuestionIndex) else {
            return nil
        }
        return questions[currentQuestionIndex]
    }
    
    var progressText: String {
        let total = pembahasanData?.questions.count ?? 0
        return "Soal \(currentQuestionIndex + 1) dari \(total)"
    }
    
    var canGoToPrevious: Bool {
        currentQuestionIndex > 0
    }
    
    var isLastQuestion: Bool {
        guard let total = pembahasanData?.questions.count else { return true }
        return currentQuestionIndex == total - 1
    }
    
    func fetchPembahasan(tryoutCode: String) async {
        isLoading = true
        errorMessage = nil
        
        // Fetch both results and pembahasan in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchResults(tryoutCode: tryoutCode)
            }
            
            group.addTask {
                await self.fetchPembahasanData(tryoutCode: tryoutCode)
            }
        }
        
        isLoading = false
    }
    
    private func fetchResults(tryoutCode: String) async {
        do {
            let response: TryOutResultsResponse = try await APIService.shared.performRequest(
              endpoint: .getTryOutResult(tryoutCode: tryoutCode),
                method: .GET,
                responseType: TryOutResultsResponse.self
            )
            
            if response.success {
                self.resultsData = response.data
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func fetchPembahasanData(tryoutCode: String) async {
        do {
            let response: PembahasanResponse = try await APIService.shared.performRequest(
                endpoint: .getPembahasan(tryoutCode: tryoutCode),
                method: .GET,
                responseType: PembahasanResponse.self
            )
            
            if response.success {
                self.pembahasanData = response.data
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func goToNextQuestion() {
        guard let total = pembahasanData?.questions.count, currentQuestionIndex < total - 1 else { return }
        currentQuestionIndex += 1
    }
    
    func goToPreviousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
    }
    
    func goToQuestion(at index: Int) {
        guard let total = pembahasanData?.questions.count, index >= 0, index < total else { return }
        currentQuestionIndex = index
    }
}
