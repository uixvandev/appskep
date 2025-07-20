import SwiftUI

struct TryOutView: View {
    let tryOutId: Int
    @StateObject private var viewModel = TryOutViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let detail = viewModel.tryOutDetail, let soal = viewModel.currentSoal {
                VStack {
                    headerView(paketName: detail.paket.name)
                    
                    ScrollView {
                        questionView(soal: soal)
                            .padding()
                    }
                    
                    navigationButtons()
                }
            } else if let error = viewModel.errorMessage {
                Text("Gagal memuat soal: \(error)")
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchTryOutDetail(tryOutId: tryOutId)
            }
        }
        .sheet(isPresented: $viewModel.showOverview) {
            if let detail = viewModel.tryOutDetail {
                TryOutOverviewSheet(
                    totalSoal: detail.soals.count,
                    answeredSoalIds: [], // Logic for this can be added to ViewModel
                    currentSoalIndex: $viewModel.currentSoalIndex
                )
            }
        }
    }
    
    private func headerView(paketName: String) -> some View {
        HStack {
          VStack(alignment: .leading) {
                Text(paketName)
                    .font(.headline)
                Text(viewModel.timeRemainingFormatted)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { viewModel.showOverview = true }) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title2)
                    .foregroundColor(.main)
            }
        }
        .padding()
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
                    viewModel.selectAnswer(optionId: option.id)
                }
            }
        }
    }
    
    private func navigationButtons() -> some View {
        HStack {
            Button(action: viewModel.goToPreviousSoal) {
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
                    viewModel.finishTryOut()
                } else {
                    viewModel.goToNextSoal()
                }
            }) {
                Text(viewModel.isLastSoal ? "Selesai" : "Selanjutnya ›")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        TryOutView(tryOutId: 69)
    }
}
