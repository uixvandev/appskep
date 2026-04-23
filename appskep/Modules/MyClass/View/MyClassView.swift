//
//  MyClassView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct MyClassView: View {
  @EnvironmentObject private var viewModel: MyClassViewModel
  @State private var needsRefreshFromPayment = false
  @State private var isPullRefreshing = false
  @State private var selectedOrder: MyOrder?
  @State private var showOrderDetail = false
  @State private var pendingOrderNumber: String?
  @State private var pendingClassCode: String?
  
  var body: some View {
    ZStack(alignment: .top) {
      // Background
      Color(.systemGray6)
        .ignoresSafeArea()
      
      // Top inline refresh indicator
      if viewModel.isRefreshing || isPullRefreshing {
        ProgressView()
          .scaleEffect(0.8)
          .padding(.top, 8)
      }
      
      Group {
        if viewModel.isLoading && viewModel.myPaidClasses.isEmpty {
          LoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.myPaidClasses.isEmpty {
          ScrollView {
            LazyVStack(spacing: 16) {
              ForEach(viewModel.myPaidClasses) { order in
                NavigationLink(destination: MyClassDetailView(order: order)) {
                  MyClassRowView(order: order)
                }
                .buttonStyle(PlainButtonStyle())
              }
              
              // Pagination footer: spinner or sentinel to load more
              if viewModel.isLoadingMore {
                ProgressView()
                  .frame(height: 60)
              } else if viewModel.hasMorePages && !viewModel.isRefreshing && !viewModel.isLoading {
                Color.clear
                  .frame(height: 1)
                  .onAppear {
                    Task { await viewModel.loadMoreClasses() }
                  }
              }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
          }
          .refreshable {
            guard !viewModel.isRefreshing && !viewModel.isLoading && !viewModel.isLoadingMore else { return }
            isPullRefreshing = true
            await viewModel.refreshMyClasses()
            isPullRefreshing = false
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
    }
    .navigationTitle("Kelas Saya")
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      Task {
        // If first load
        if viewModel.myPaidClasses.isEmpty {
          await viewModel.fetchMyClasses()
        }
        // If flagged from payment, refresh
        if needsRefreshFromPayment {
          needsRefreshFromPayment = false
          await viewModel.refreshMyClasses()
        }
        openPendingOrderIfPossible()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMyClasses"))) { _ in
      // Debounce: set flag and let onAppear perform refresh once when visible
      needsRefreshFromPayment = true
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMyClassesWithRetry"))) { _ in
      Task {
        await viewModel.refreshWithRetry()
        openPendingOrderIfPossible()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenMyClassDetail"))) { notification in
      pendingOrderNumber = notification.userInfo?["orderNumber"] as? String
      pendingClassCode = notification.userInfo?["classCode"] as? String
      Task {
        await viewModel.refreshWithRetry()
        openPendingOrderIfPossible()
      }
    }
    .navigationDestination(isPresented: $showOrderDetail) {
      if let order = selectedOrder {
        MyClassDetailView(order: order)
      }
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

  private func openPendingOrderIfPossible() {
    guard !showOrderDetail else { return }

    if let pendingOrderNumber = pendingOrderNumber,
       let order = viewModel.myPaidClasses.first(where: { $0.order_number == pendingOrderNumber }) {
      selectedOrder = order
      showOrderDetail = true
      self.pendingOrderNumber = nil
      self.pendingClassCode = nil
      return
    }

    if let pendingClassCode = pendingClassCode,
       let order = viewModel.myPaidClasses.first(where: { $0.kelas.class_code == pendingClassCode }) {
      selectedOrder = order
      showOrderDetail = true
      self.pendingOrderNumber = nil
      self.pendingClassCode = nil
    }
  }
}

// MARK: - Supporting Views

struct MyClassRowView: View {  // Renamed from MyClassCardView
  let order: MyOrder
  
  var body: some View {
    HStack(spacing: 16) {
      // Modern Icon Container
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [Color.main, Color.main.opacity(0.8)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 64, height: 64)
        
        Image(systemName: "graduationcap.fill")
          .font(.system(size: 28, weight: .medium))
          .foregroundColor(.white)
      }
      
      // Content
      VStack(alignment: .leading, spacing: 8) {
        Spacer(minLength: 0)
        
        // Title
        Text(order.kelas.name)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
        
        // Description (limit to 1 line for consistent height)
        Text(order.kelas.description)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .lineLimit(1)
          .multilineTextAlignment(.leading)
        
        Text("Aktif")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.green)
        
        Spacer(minLength: 0)
      }
      .frame(maxHeight: .infinity, alignment: .center)
      Spacer()
      // Chevron
      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.gray)  // Fixed: Use .gray instead of .tertiary
    }
    .padding()
    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
    .background(Color(.systemBackground))
    .cornerRadius(20)
    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color(.systemGray5), lineWidth: 0.5)
    )
  }
}

struct EmptyMyClassView: View {
  var body: some View {
    VStack(spacing: 32) {
      // Illustration
      VStack(spacing: 20) {
        ZStack {
          Circle()
            .fill(Color.main.opacity(0.1))
            .frame(width: 120, height: 120)
          
          Image(systemName: "book.closed.fill")
            .font(.system(size: 50, weight: .light))
            .foregroundColor(.main)
        }
        
        VStack(spacing: 12) {
          Text("Belum Ada Kelas")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
          
          Text("Mulai perjalanan belajar Anda dengan membeli kelas UKOM yang tersedia")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .padding(.horizontal, 20)
        }
      }
      
      // CTA Button
      NavigationLink(destination: SearchClassView()) {
        HStack(spacing: 12) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 18, weight: .medium))
          
          Text("Jelajahi Kelas")
            .font(.headline)
            .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
          LinearGradient(
            colors: [Color.main, Color.main.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(16)
      }
      .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
  }
}

struct ErrorStateView: View {
  let title: String
  let message: String
  let onRetry: () -> Void
  
  var body: some View {
    VStack(spacing: 32) {
      // Error illustration
      VStack(spacing: 20) {
        ZStack {
          Circle()
            .fill(Color.orange.opacity(0.1))
            .frame(width: 120, height: 120)
          
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 50, weight: .light))
            .foregroundColor(.orange)
        }
        
        VStack(spacing: 12) {
          Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
          
          Text(message)
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .padding(.horizontal, 20)
        }
      }
      
      // Retry button
      Button(action: onRetry) {
        HStack(spacing: 12) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 18, weight: .medium))
          
          Text("Coba Lagi")
            .font(.headline)
            .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.main)
        .cornerRadius(16)
      }
      .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
  }
}

#Preview {
  NavigationStack {
    MyClassView()
      .environmentObject(MyClassViewModel())
  }
}
