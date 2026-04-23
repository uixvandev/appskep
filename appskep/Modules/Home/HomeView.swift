//
//  HomeView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var authManager: AuthManager
  @EnvironmentObject var myClassViewModel: MyClassViewModel
  @StateObject private var searchViewModel = SearchViewModel()
  @StateObject private var notificationViewModel = NotificationViewModel()
  @State private var showNotifications = false
  @Environment(\.scenePhase) private var scenePhase
  
  private let newClassesColumns: [GridItem] = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
  ]
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        // Header dengan salam dan notifikasi
        headerView
        
        // Promo Banner
        promoBanner
        
        // Kelas Saya Section
        myClassesSection
        
        // Kelas Terbaru Section
        newClassesSection
      }
      .padding()
    }
    .navigationBarHidden(true)
    .onAppear {
      Task {
        await myClassViewModel.fetchMyClasses()
        await searchViewModel.fetchUkomClasses()
        await notificationViewModel.fetchUnreadCount()
      }
      notificationViewModel.startUnreadAutoRefresh()
    }
    .onDisappear {
      notificationViewModel.stopUnreadAutoRefresh()
    }
    .onChange(of: scenePhase) { _, phase in
      switch phase {
      case .active:
        notificationViewModel.startUnreadAutoRefresh()
      case .background, .inactive:
        notificationViewModel.stopUnreadAutoRefresh()
      @unknown default:
        break
      }
    }
    .sheet(isPresented: $showNotifications) {
      NavigationStack {
        NotificationView()
          .environmentObject(notificationViewModel)
      }
    }
  }
  
  // Adaptive polling moved to NotificationViewModel (startUnreadAutoRefresh/stopUnreadAutoRefresh)
  
  private var headerView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        // Ambil kata depan saja dari nama
        Text("Hai \(getFirstName()),")
          .font(.title2)
          .fontWeight(.bold)
        
        Text("Sudahkah kamu latihan soal hari ini?")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Button(action: {
        showNotifications = true
      }) {
        ZStack {
          Image(systemName: "bell.fill")
            .font(.title2)
            .foregroundColor(.main)
            .frame(width: 40, height: 40)
            .background(Color.main.opacity(0.1))
            .cornerRadius(20)
          
          // Badge for unread notifications
          if notificationViewModel.unreadCount > 0 {
            Text("\(notificationViewModel.unreadCount)")
              .font(.caption2)
              .fontWeight(.bold)
              .foregroundColor(.white)
              .frame(minWidth: 16, minHeight: 16)
              .background(Color.red)
              .cornerRadius(8)
              .offset(x: 12, y: -12)
          }
        }
      }
    }
  }
  
  private var promoBanner: some View {
    Image("Banner")
      .resizable()
      .scaledToFit()
      .frame(maxWidth: .infinity)
      .clipped()
  }
  
  private var myClassesSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Kelas saya")
          .font(.headline)
          .fontWeight(.bold)
        
        Spacer()
        
        if !myClassViewModel.myPaidClasses.isEmpty {
          NavigationLink("Lihat semua", destination: MyClassView())
            .font(.caption)
            .foregroundColor(.main)
        }
      }
      
      if myClassViewModel.isLoading && myClassViewModel.myPaidClasses.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding()
      } else if myClassViewModel.myPaidClasses.isEmpty {
        EmptyMyClassesView()
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(myClassViewModel.myPaidClasses.prefix(5)) { order in
              NavigationLink(destination: MyClassDetailView(order: order)) {
                MyClassCardView(order: order)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding(.horizontal, 4)
        }
      }
    }
  }
  
  private var newClassesSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Kelas terbaru")
          .font(.headline)
          .fontWeight(.bold)
        
        Spacer()
        
        NavigationLink("Lihat semua", destination: SearchClassView())
          .font(.caption)
          .foregroundColor(.main)
      }
      
      if searchViewModel.isLoading && searchViewModel.ukomClasses.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding()
      } else {
        LazyVGrid(columns: newClassesColumns, spacing: 16) {
          ForEach(searchViewModel.ukomClasses.prefix(4)) { ukomClass in
            NavigationLink(destination: SearchClassDetailView(classCode: ukomClass.class_code)) {
              ClassCardView(ukomClass: ukomClass)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
    }
  }
  
  // Helper function untuk mengambil nama depan saja
  private func getFirstName() -> String {
    guard let name = authManager.currentUser?.name else { return "User" }
    return String(name.split(separator: " ").first ?? "User")
  }
}

// MARK: - Supporting Views

struct MyClassCardView: View {
  let order: MyOrder
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Icon
      Image(systemName: "book.closed.fill")
        .font(.title2)
        .foregroundColor(.white)
        .frame(width: 40, height: 40)
        .background(Color.main)
        .cornerRadius(20)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(order.kelas.name)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
        
        Text(order.kelas.description)
          .font(.caption)
          .foregroundColor(.white.opacity(0.8))
          .lineLimit(2)
          .multilineTextAlignment(.leading)
      }
      
      Spacer()
    }
    .padding()
    .frame(width: 200, height: 140)
    .background(
      LinearGradient(
        colors: [Color.main, Color.main.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
  }
}

struct EmptyMyClassesView: View {
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "book.closed")
        .font(.system(size: 40))
        .foregroundColor(.secondary)
      
      Text("Belum ada kelas")
        .font(.headline)
        .foregroundColor(.secondary)
      
      Text("Beli kelas untuk mulai belajar")
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
      
      NavigationLink("Cari kelas", destination: SearchClassView())
        .font(.caption)
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.main)
        .cornerRadius(20)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
}

#Preview {
  HomeView()
    .environmentObject(AuthManager.shared)
    .environmentObject(MyClassViewModel())
}
