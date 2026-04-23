//
//  OrderRowView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct OrderRowView: View {
    let order: OrderItem
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.kelas.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("Order #\(order.order_number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadgeView(status: order.status)
            }
            
            // Amount and Date
            HStack {
                Text(order.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.main)
                
                Spacer()
                
                Text(order.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Detail Button
                Button(action: {
                    viewModel.showOrderDetailSheet(order: order)
                }) {
                    Text("Detail")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.main)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.main.opacity(0.1))
                        .cornerRadius(16)
                }
                
                Spacer()
                
                // Status-based Action Button
                actionButton(for: order)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private func actionButton(for order: OrderItem) -> some View {
        switch order.status {
        case .pending:
            if order.canPay {
                Button(action: {
                    viewModel.proceedToPayment(order: order)
                }) {
                    Text("Bayar Sekarang")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
            }
            
        case .success:
            Button(action: {
                // Navigate to class
                Task {
                    let hasAccess = await viewModel.checkClassAccess(classCode: order.class_code)
                    if hasAccess {
                        viewModel.openClass(order: order)
                    }
                }
            }) {
                Text("Akses Kelas")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(16)
            }
            
        case .failed:
            Button(action: {
                viewModel.retryOrder(order: order)
            }) {
                Text("Buat Order Baru")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(16)
            }
            
        case .cancel:
            EmptyView()
        }
    }
}

#Preview {
    OrderRowView(
        order: OrderItem(
            order_number: "appskep001",
            class_code: "UKOM-001",
            email: "john@example.com",
            status: .pending,
            payment_reference: "TXN123456",
            gross_amount: 299000,
            snap_token: nil,
            snap_redirect_url: "https://example.com",
            created_at: "2025-01-01T10:00:00Z",
            updated_at: "2025-01-01T10:00:00Z",
            kelas: KelasInfo(class_code: "UKOM-001", name: "Kelas UKOM Keperawatan Premium", description: "Kelas persiapan UKOM terlengkap", price: 299000)
        )
    )
    .environmentObject(TransactionViewModel())
    .padding()
}
