//
//  FilterSheetView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Filter Transaksi")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(OrderFilter.allCases, id: \.self) { filter in
                        FilterOptionView(
                            filter: filter,
                            isSelected: viewModel.selectedFilter == filter
                        ) {
                            viewModel.applyFilter(filter)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct FilterOptionView: View {
    let filter: OrderFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(filter.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if filter != .all {
                        Text("Status: \(filter.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.main)
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? Color.main.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FilterSheetView()
        .environmentObject(TransactionViewModel())
}
