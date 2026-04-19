//
//  OrderDetailView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct OrderDetailView: View {
    let order: OrderItem
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedClassOrder: MyOrder?
    @State private var showClassDetail = false
    @State private var isFetchingClassDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Status Card
                    statusCard
                    
                    // Order Information
                    orderInfoCard
                    
                    // Class Information
                    classInfoCard
                    
                    // Payment Information
                    paymentInfoCard
                    
                    // Action Button
                    actionButtonSection
                }
                .padding()
            }
            .navigationTitle("Detail Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showClassDetail) {
                if let order = selectedClassOrder {
                    MyClassDetailView(order: order)
                }
            }
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            StatusBadgeView(status: order.status)
            
            Text(order.formattedAmount)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.main)
            
            Text("Order #\(order.order_number ?? order.id)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var orderInfoCard: some View {
        InfoCardView(title: "Informasi Pesanan") {
            InfoRowView(label: "Tanggal Pemesanan", value: order.formattedDate)
            InfoRowView(label: "Referensi Pembayaran", value: order.payment_reference)
            InfoRowView(label: "Status", value: order.status.displayName)
        }
    }
    
    private var classInfoCard: some View {
        InfoCardView(title: "Informasi Kelas") {
            InfoRowView(label: "Nama Kelas", value: order.kelas.name)
            InfoRowView(label: "Deskripsi", value: order.kelas.description)
            InfoRowView(label: "Harga", value: "Rp \(order.kelas.price.formatted(.number))")
        }
    }
    
    private var paymentInfoCard: some View {
        InfoCardView(title: "Informasi Pembayaran") {
            InfoRowView(label: "Total Pembayaran", value: order.formattedAmount)
            InfoRowView(label: "Metode Pembayaran", value: "Midtrans")
            
            if let snapToken = order.snap_token {
                InfoRowView(label: "Token Pembayaran", value: snapToken)
            }
        }
    }
    
    private var actionButtonSection: some View {
        VStack(spacing: 12) {
            switch order.status {
            case .pending:
                if order.canPay {
                    Button(action: {
                        viewModel.proceedToPayment(order: order)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Lanjutkan Pembayaran")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange)
                        .cornerRadius(16)
                    }
                }
                
            case .paid:
                Button(action: {
                    Task {
                        guard !isFetchingClassDetail else { return }
                        isFetchingClassDetail = true
                        let hasAccess = await viewModel.checkClassAccess(kelasId: order.kelas_id)
                        if hasAccess, let kelas = await viewModel.fetchKelasDetail(kelasId: order.kelas_id) {
                            selectedClassOrder = MyOrder(id: order.id, status: order.status.rawValue, kelas: kelas)
                            showClassDetail = true
                        }
                        isFetchingClassDetail = false
                    }
                }) {
                    HStack {
                        if isFetchingClassDetail {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "book.fill")
                        }
                        Text(isFetchingClassDetail ? "Memuat..." : "Akses Kelas")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(16)
                }
                .disabled(isFetchingClassDetail)
                
            case .expired, .failure:
                Button(action: {
                    viewModel.retryOrder(order: order)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Buat Order Baru")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(16)
                }
                
            case .cancel:
                Text("Pesanan ini telah dibatalkan")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
            }
        }
    }
}

// MARK: - Supporting Views
struct InfoCardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.main)
            
            VStack(spacing: 8) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    OrderDetailView(
        order: OrderItem(
            id: 1,
            order_number: 12345,
            kelas_id: 1,
            status: .pending,
            payment_reference: "TXN123456",
            gross_amount: 299000,
            snap_token: "snap_token_example",
            snap_redirect_url: "https://example.com",
            created_at: "2025-01-01T10:00:00Z",
            updated_at: "2025-01-01T10:00:00Z",
            user: UserInfo(id: 1, name: "John Doe", email: "john@example.com"),
            kelas: KelasInfo(id: 1, name: "Kelas UKOM Keperawatan Premium", description: "Kelas persiapan UKOM terlengkap", price: 299000)
        )
    )
    .environmentObject(TransactionViewModel())
}
