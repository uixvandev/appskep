//
//  SearchClassDetailView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI
import SafariServices

struct SearchClassDetailView: View {
  let classId: Int
  @StateObject private var viewModel = SearchClassDetailViewModel()
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    ZStack(alignment: .bottom) {
      if viewModel.isLoading {
        LoadingView()
      } else if let ukomClass = viewModel.ukomClass {
        // Main content
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
              Text(ukomClass.name)
                .font(.title)
                .fontWeight(.bold)
              
              Text(ukomClass.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading) // Fixed alignment
            }
            
            // Paket List
            VStack(alignment: .leading, spacing: 16) {
              Text("Materi Try Out")
                .font(.headline)
              
              ForEach(viewModel.pakets) { paket in
                PaketRowView(paket: paket)
              }
            }
            
            // Bottom spacing for floating button
            Rectangle()
              .fill(Color.clear)
              .frame(height: 80) // Reduced from 100
          }
          .padding()
        }
        
        // Floating Button at bottom
        VStack(spacing: 0) {
          // Gradient overlay to blend with content
          LinearGradient(
            colors: [Color.clear, Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
          )
          .frame(height: 20)
          
          // Button container
          VStack(spacing: 0) {
            Button {
              Task {
                await viewModel.buyClass(classId: ukomClass.id)
              }
            } label: {
              CustomLongButton(
                title: "Beli kelas Rp \(ukomClass.price.formatted(.number))",
                titleColor: .white,
                bgButtonColor: .main
              )
            }
            .disabled(viewModel.isLoading)
            
            // Safe area bottom padding
            Rectangle()
              .fill(Color(.systemBackground))
              .frame(height: getSafeAreaBottom())
          }
          .padding(.horizontal)
          .background(Color(.systemBackground))
        }
        
      } else if let errorMessage = viewModel.errorMessage {
        // Error state
        VStack(spacing: 20) {
          Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 60))
            .foregroundColor(.orange)
          
          Text("Gagal Memuat Detail")
            .font(.title2)
            .fontWeight(.bold)
          
          Text(errorMessage)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal, 32)
          
          Button("Coba Lagi") {
            Task {
              await viewModel.fetchAllDetails(id: classId)
            }
          }
          .font(.headline)
          .foregroundColor(.white)
          .frame(width: 140, height: 44)
          .background(Color.main)
          .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .navigationTitle("Detail Kelas")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: { dismiss() }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
            Text("Kembali")
          }
          .foregroundColor(.main)
        }
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchAllDetails(id: classId)
      }
    }
    // Regular order error alert
    .alert("Gagal", isPresented: $viewModel.showOrderAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(viewModel.orderError ?? "Terjadi kesalahan")
    }
    // Duplicate order alert with navigation fix
    .alert("Kelas Sudah Dimiliki", isPresented: $viewModel.showDuplicateOrderAlert) {
      Button("Buka Kelas Saya") {
        navigateToMyClasses()
      }
      Button("OK", role: .cancel) { }
    } message: {
      Text(viewModel.duplicateOrderMessage ?? "Anda sudah memiliki akses ke kelas ini.")
    }
    .sheet(isPresented: $viewModel.showWebView) {
      if let url = viewModel.redirectURL {
        SafariView(url: url)
      }
    }
  }
  
  // MARK: - Helper Methods
  
  private func navigateToMyClasses() {
    // Dismiss current view first
    dismiss()
    
    // Post notification to switch to MyClass tab
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      NotificationCenter.default.post(
        name: NSNotification.Name("SwitchToMyClassTab"),
        object: nil
      )
    }
  }
  
  private func getSafeAreaBottom() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      return 34 // Default bottom safe area
    }
    return window.safeAreaInsets.bottom
  }
}

struct PaketRowView: View {
  let paket: Paket
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(paket.name)
        .font(.headline)
        .lineLimit(2)
      
      HStack {
        HStack(spacing: 4) {
          Image(systemName: "clock")
            .font(.caption)
            .foregroundColor(.secondary)
          Text("\(paket.duration) menit")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        if let totalQuestions = paket.totalQuestions {
          HStack(spacing: 4) {
            Image(systemName: "questionmark.circle")
              .font(.caption)
              .foregroundColor(.secondary)
            Text("\(totalQuestions) soal")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}

#Preview {
  SearchClassDetailView(classId: 1)
}
