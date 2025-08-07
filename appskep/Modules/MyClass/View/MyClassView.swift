//
//  MyClassView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct MyClassView: View {
  @StateObject private var viewModel = MyClassViewModel()
  
  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading && viewModel.myPaidClasses.isEmpty {
          LoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.myPaidClasses.isEmpty {
          List(viewModel.myPaidClasses) { order in
            NavigationLink(destination: MyClassDetailView(order: order)) {
              MyClassRowView(order: order)
            }
            .onAppear {
              // Load more when reaching last item
              if order.id == viewModel.myPaidClasses.last?.id {
                Task {
                  await viewModel.loadMoreClasses()
                }
              }
            }
          }
          .listStyle(.plain)
          .refreshable {
            await viewModel.refreshMyClasses()
          }
        } else if viewModel.errorMessage != nil {
          // Error state
          ErrorStateView(
            title: "Gagal Memuat Kelas",
            message: viewModel.errorMessage ?? "Terjadi kesalahan saat memuat kelas Anda",
            onRetry: {
              Task {
                await viewModel.refreshMyClasses()
              }
            }
          )
        } else {
          // Empty state
          EmptyMyClassView()
        }
      }
      .navigationTitle("Kelas Saya")
      .onAppear {
        Task {
          await viewModel.fetchMyClasses()
        }
      }
      .refreshable {
        await viewModel.refreshMyClasses()
      }
      .alert("Error", isPresented: .constant(viewModel.errorMessage != nil && !viewModel.myPaidClasses.isEmpty)) {
        Button("OK") {
          viewModel.clearError()
        }
        Button("Refresh") {
          Task {
            await viewModel.refreshMyClasses()
          }
        }
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
    }
  }
}

// MARK: - Supporting Views
struct MyClassRowView: View {
  let order: MyOrder
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        // Class icon
        Image(systemName: "book.fill")
          .font(.title2)
          .foregroundColor(.white)
          .frame(width: 40, height: 40)
          .background(Color.main)
          .cornerRadius(20)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(order.kelas.name)
            .font(.headline)
            .lineLimit(2)
          
          Text(order.kelas.description)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
        
        Spacer()
        
        // Status badge
        Text("Aktif")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.green)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.green.opacity(0.1))
          .cornerRadius(12)
      }
      
      // Price info
      HStack {
        Text("Rp \(order.kelas.price.formatted(.number))")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(.main)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
  }
}

struct EmptyMyClassView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "book.closed")
        .font(.system(size: 60))
        .foregroundColor(.secondary)
      
      VStack(spacing: 8) {
        Text("Belum Ada Kelas")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Anda belum memiliki kelas yang dibeli. Beli kelas untuk mulai belajar dan berlatih soal UKOM.")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .lineLimit(4)
      }
      
      NavigationLink(destination: SearchClassView()) {
        Text("Cari Kelas")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.main)
          .cornerRadius(16)
      }
      .padding(.horizontal, 32)
    }
    .padding(.horizontal, 32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct ErrorStateView: View {
  let title: String
  let message: String
  let onRetry: () -> Void
  
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 60))
        .foregroundColor(.orange)
      
      VStack(spacing: 8) {
        Text(title)
          .font(.title2)
          .fontWeight(.semibold)
        
        Text(message)
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .lineLimit(4)
      }
      
      Button(action: onRetry) {
        Text("Coba Lagi")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.main)
          .cornerRadius(16)
      }
      .padding(.horizontal, 32)
    }
    .padding(.horizontal, 32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  NavigationStack {
    MyClassView()
  }
}
