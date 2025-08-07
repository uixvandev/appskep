//
//  NotificationView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//


import SwiftUI

struct NotificationView: View {
    @EnvironmentObject private var viewModel: NotificationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - State Properties
    @State private var refreshTimer: Timer?
    @State private var searchText = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            notificationList
        }
        .navigationTitle("Notifikasi")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            toolbarContent
        }
        .onAppear {
            handleViewAppear()
        }
        .onDisappear {
            handleViewDisappear()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .refreshable {
            await viewModel.refreshNotifications()
        }
    }
}

// MARK: - View Components
private extension NotificationView {
    
    var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                
                if !searchText.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .transition(.opacity)
                }
                
                Spacer()
                
                Image(systemName: "mic.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
    
    var notificationList: some View {
        List {
            if filteredNotifications.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                notificationItems
            }
            
            if viewModel.isLoading {
                loadingView
            }
        }
        .listStyle(.plain)
    }
    
    var notificationItems: some View {
        ForEach(filteredNotifications) { notification in
            NotificationRowView(notification: notification) {
                await handleNotificationTap(notification)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .onAppear {
                handleNotificationAppear(notification)
            }
        }
    }
    
    var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
        .frame(height: 60)
        .listRowSeparator(.hidden)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "bell.slash" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Belum Ada Notifikasi" : "Tidak Ada Hasil Pencarian")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if viewModel.isAutoRefreshing {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Auto refresh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: handleManualRefresh) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(viewModel.isLoading ? .secondary : .accentColor)
                    .font(.system(size: 18, weight: .medium))
            }
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Computed Properties
private extension NotificationView {
    
    var filteredNotifications: [NotificationItem] {
        if searchText.isEmpty {
            return viewModel.notifications
        } else {
            return viewModel.notifications.filter { notification in
                notification.title.localizedCaseInsensitiveContains(searchText) ||
                notification.description.localizedCaseInsensitiveContains(searchText) ||
                notification.order_details.kelas_name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var emptyStateMessage: String {
        if searchText.isEmpty {
            return "Notifikasi akan muncul di sini ketika ada update tentang pesanan atau aktivitas Anda."
        } else {
            return "Coba gunakan kata kunci yang berbeda untuk pencarian Anda."
        }
    }
}

// MARK: - Event Handlers
private extension NotificationView {
    
    func handleViewAppear() {
        setupAutoRefresh()
        if viewModel.notifications.isEmpty {
            Task {
                await viewModel.fetchNotifications()
            }
        }
    }
    
    func handleViewDisappear() {
        stopAutoRefresh()
    }
    
    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            setupAutoRefresh()
            Task {
                await viewModel.refreshNotifications()
            }
        case .inactive, .background:
            stopAutoRefresh()
        @unknown default:
            break
        }
    }
    
    func handleNotificationTap(_ notification: NotificationItem) async {
        await viewModel.markAsRead(notification)
    }
    
    func handleNotificationAppear(_ notification: NotificationItem) {
        // Pagination: Load more when reaching the last item
        if notification.id == viewModel.notifications.last?.id {
            Task {
                await viewModel.fetchNotifications()
            }
        }
    }
    
    func handleManualRefresh() {
        Task {
            await viewModel.refreshNotifications()
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
}

// MARK: - Auto Refresh Functions
private extension NotificationView {
    
    func setupAutoRefresh() {
        stopAutoRefresh()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                await viewModel.autoRefreshNotifications()
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        viewModel.setAutoRefreshing(false)
    }
}

// MARK: - NotificationRowView
struct NotificationRowView: View {
    let notification: NotificationItem
    let onTap: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await onTap()
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                headerRow
                dateRow
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundView)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - NotificationRowView Components
private extension NotificationRowView {
    
    var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(notification.title)
                .font(.headline)
                .fontWeight(notification.is_read ? .medium : .semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer(minLength: 8)
            
            if !notification.is_read {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
    }
    
    var dateRow: some View {
        Text(formatNotificationDate(notification.created_at))
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(notification.is_read ? Color.clear : Color.accentColor.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        notification.is_read ? Color(.systemGray5) : Color.clear,
                        lineWidth: notification.is_read ? 1 : 0
                    )
            )
    }
    
    // Helper function untuk format date
    private func formatNotificationDate(_ dateString: String) -> String {
        let date = DateParser.parseNotificationDate(from: dateString) ?? Date()
        return NotificationDateFormatter.format(date: date)
    }
}

// MARK: - DateParser Utility
struct DateParser {
    static func parseNotificationDate(from dateString: String) -> Date? {
        let formatters: [DateFormatter] = [
            iso8601WithFractionalSeconds,
            iso8601Standard,
            customAPIFormat,
            fallbackFormat
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        // Debug log for unparseable dates
        print("⚠️ Failed to parse date: '\(dateString)'")
        return nil
    }
    
    private static let iso8601WithFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let iso8601Standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let customAPIFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let fallbackFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - NotificationDateFormatter Utility
struct NotificationDateFormatter {
    static func format(date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Hari ini, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Kemarin, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "dd MMM yyyy • HH:mm 'WIB'"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        NotificationView()
            .environmentObject(NotificationViewModel())
    }
}
