//
//  TryOutHistoryView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct TryOutHistoryView: View {
    @StateObject private var viewModel = TryOutHistoryViewModel()
    
    var body: some View {
        List {
            if viewModel.historyItems.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                ForEach(viewModel.historyItems) { item in
                    historyRowView(for: item)
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Riwayat Try Out")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.historyItems.isEmpty {
                Task {
                    await viewModel.refreshHistory()
                }
            }
        }
        .refreshable {
            await viewModel.refreshHistory()
        }
    }
    
    @ViewBuilder
    private func historyRowView(for item: TryOutHistoryItem) -> some View {
        if item.finished_at != nil {
            NavigationLink(destination: PembahasanView(tryOutId: item.id)) {
                TryOutHistoryRow(item: item)
            }
            .onAppear {
                loadMoreIfNeeded(for: item)
            }
        } else {
            TryOutHistoryRow(item: item)
                .opacity(0.6)
                .onAppear {
                    loadMoreIfNeeded(for: item)
                }
        }
    }
    
    private func loadMoreIfNeeded(for item: TryOutHistoryItem) {
        // Load more data when the last item appears
        if item.id == viewModel.historyItems.last?.id {
            Task {
                await viewModel.fetchHistory()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Belum Ada Riwayat")
                .font(.headline)
            Text("Anda belum pernah menyelesaikan try out. Selesaikan try out untuk melihat riwayatnya di sini.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct TryOutHistoryRow: View {
    let item: TryOutHistoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.paket.name)
                    .font(.headline)
                    .lineLimit(2)
                
                // Tampilkan status berdasarkan finished_at
                if item.finished_at != nil {
                    Text("Selesai: \(formatDate(item.finished_at))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.orange)
                        Text("Sedang Dikerjakan")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Tampilkan skor jika ada
            VStack(alignment: .trailing) {
                if let score = item.score {
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.main)
                    Text("Skor")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("-")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    Text("N/A")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // Update formatDate untuk menerima String?
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "id_ID")
            return formatter.string(from: date)
        }
        return "N/A"
    }
}

#Preview {
    NavigationStack {
        TryOutHistoryView()
    }
}
