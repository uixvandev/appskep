//
//  TransactionView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                // Order List
                orderListView
            }
            .navigationTitle("Riwayat Transaksi")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.main)
                    }
                }
            }
            .onAppear {
                if viewModel.orders.isEmpty {
                    Task {
                        await viewModel.fetchOrders()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshOrders()
            }
            .sheet(isPresented: $viewModel.showOrderDetail) {
                if let order = viewModel.selectedOrder {
                    OrderDetailView(order: order)
                        .environmentObject(viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheetView()
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showPaymentWebView) {
                if let url = viewModel.paymentURL {
                    PaymentWebView(url: url)
                        .environmentObject(viewModel)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
                Button("Coba Lagi") {
                    Task {
                        await viewModel.refreshOrders()
                    }
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Cari berdasarkan nama kelas atau referensi...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: viewModel.clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Active Filter Indicator
            if viewModel.selectedFilter != .all {
                HStack {
                    Text("Filter: \(viewModel.selectedFilter.displayName)")
                        .font(.caption)
                        .foregroundColor(.main)
                    
                    Spacer()
                    
                    Button("Hapus Filter") {
                        viewModel.selectedFilter = .all
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var orderListView: some View {
        Group {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                LoadingView()
            } else if viewModel.filteredAndSearchedOrders.isEmpty && !viewModel.isLoading && !viewModel.isRefreshing {
                // Only show empty state when not loading and not refreshing
                EmptyStateView(
                    title: viewModel.searchText.isEmpty ? "Belum Ada Transaksi" : "Tidak Ditemukan",
                    message: viewModel.searchText.isEmpty ?
                        "Transaksi akan muncul di sini setelah Anda melakukan pembelian kelas." :
                        "Coba gunakan kata kunci yang berbeda untuk pencarian Anda.",
                    systemImage: viewModel.searchText.isEmpty ? "creditcard" : "magnifyingglass"
                )
            } else {
                List {
                    ForEach(viewModel.filteredAndSearchedOrders) { order in
                        OrderRowView(order: order)
                            .environmentObject(viewModel)
                            .onAppear {
                                // Load more when reaching last item
                                if order.id == viewModel.orders.last?.id {
                                    Task {
                                        await viewModel.loadMoreOrders()
                                    }
                                }
                            }
                    }
                    
                    // Loading more indicator
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Memuat lebih banyak...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionView()
    }
}
