//
//  StatusBadgeView.swift
//  appskep
//
//  Created by irfan wahendra on 03/08/25.
//

import SwiftUI

struct StatusBadgeView: View {
    let status: OrderStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(OrderStatus.allCases, id: \.self) { status in
            StatusBadgeView(status: status)
        }
    }
    .padding()
}
