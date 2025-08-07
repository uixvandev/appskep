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
                    // Only allow navigation if try out is completed
                    if item.finished_at != nil {
                        NavigationLink(destination: PembahasanView(tryOutId: item.id)) {
                            TryOutHistoryRow(item: item)
                        }
                    } else {
                        TryOutHistoryRow(item: item)
                            .opacity(0.6) // Show incomplete try outs as disabled
                    }
                }
                .onAppear {
                    // Load more when the last item appears
                    if let lastItem = viewModel.historyItems.last {
                        Task {
                            await viewModel.fetchHistory()
                        }
                    }
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
                    await viewModel.fetchHistory()
                }
            }
        }
        .refreshable {
            await viewModel.refreshHistory()
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
                
                // Show different info based on completion status
                if let finishedAt = item.finished_at {
                    Text(formatDate(finishedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("Belum selesai")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("Dimulai: \(formatDate(item.started_at))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
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
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Belum selesai")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
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
