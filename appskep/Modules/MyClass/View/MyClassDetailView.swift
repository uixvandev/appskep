//
//  MyClassDetailView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct MyClassDetailView: View {
    let order: MyOrder
    @StateObject private var viewModel = SearchClassDetailViewModel()
    @State private var selectedPaket: Paket?
    @State private var showTryOutFullScreen = false
    @State private var tryOutId: Int?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Class Header
                classHeaderSection
                
                Divider()
                
                // Pakets Section
                paketsSection
            }
            .padding()
        }
        .navigationTitle("Detail Kelas Saya")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.fetchAllDetails(id: order.kelas.id)
            }
        }
        .sheet(item: $selectedPaket) { paket in
            NavigationStack {
                TryOutInfoSheet(paket: paket, orderId: order.id)
            }
        }
    }
    
    private var classHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(order.kelas.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(order.kelas.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var paketsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paket Try Out Tersedia")
                .font(.headline)
            
            if viewModel.isLoading {
                // Loading state
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        PaketSkeletonView()
                    }
                }
            } else if viewModel.pakets.isEmpty {
                // Empty state
                EmptyPaketsView()
            } else {
                // Pakets list
                VStack(spacing: 12) {
                    ForEach(viewModel.pakets) { paket in
                        Button(action: {
                            selectedPaket = paket
                        }) {
                            PaketRowView(paket: paket)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct EmptyPaketsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Belum Ada Paket Try Out")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Paket try out untuk kelas ini sedang dalam persiapan. Silakan cek kembali nanti.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct PaketSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 20)
                .cornerRadius(4)
            
            HStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 16)
                    .cornerRadius(4)
                
                Spacer()
                
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 16)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    NavigationStack {
        MyClassDetailView(order: MyOrder(id: 1, status: "paid", kelas: .init(id: 1, name: "Test", description: "Test", price: 1000)))
    }
}
