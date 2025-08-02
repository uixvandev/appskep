//
//  ChatMessageView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
                userMessageView
            } else {
                botMessageView
                Spacer(minLength: 50)
            }
        }
    }
    
    private var userMessageView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .padding(12)
                .background(Color.main)
                .foregroundColor(.white)
                .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
            
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var botMessageView: some View {
        HStack(alignment: .top, spacing: 8) {
            // Bot avatar
            Image(systemName: "brain.head.profile")
                .foregroundColor(.main)
                .font(.title2)
                .frame(width: 32, height: 32)
                .background(Color.main.opacity(0.1))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Askep")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.main)
                
                // Format long response text better
                Text(message.content)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

// Custom corner radius modifier (keep existing code)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatMessageView(
            message: ChatMessage(
                id: 1,
                content: "Jelaskan mengapa jawaban yang benar itu penting dalam konteks keperawatan?",
                isUser: true,
                timestamp: Date()
            )
        )
        
        ChatMessageView(
            message: ChatMessage(
                id: 2,
                content: "Halo! 👋 Aku Askep, asisten digital keperawatanmu di APPSKEP! Senang sekali bisa membantumu dalam mempersiapkan diri untuk UKOM.",
                isUser: false,
                timestamp: Date()
            )
        )
    }
    .padding()
}
