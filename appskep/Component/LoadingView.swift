//
//  LoadingView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Memuat transaksi...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SkeletonRowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 20)
                    .cornerRadius(4)
                
                Spacer()
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 16)
                    .cornerRadius(8)
            }
            
            HStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 16)
                    .cornerRadius(4)
                
                Spacer()
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 14)
                    .cornerRadius(4)
            }
            
            HStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 24)
                    .cornerRadius(12)
                
                Spacer()
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 24)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    VStack(spacing: 16) {
        LoadingView()
            .frame(height: 200)
        
        EmptyStateView(
            title: "Belum Ada Transaksi",
            message: "Transaksi akan muncul di sini setelah Anda melakukan pembelian kelas.",
            systemImage: "creditcard"
        )
        .frame(height: 200)
        
        SkeletonRowView()
    }
    .padding()
}
