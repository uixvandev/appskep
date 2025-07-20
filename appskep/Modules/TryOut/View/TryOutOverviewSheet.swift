//
//  TryOutOverviewSheet.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct TryOutOverviewSheet: View {
  let totalSoal: Int
  let answeredSoalIds: Set<Int>
  @Binding var currentSoalIndex: Int
  @Environment(\.dismiss) private var dismiss
  
  private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(0..<totalSoal, id: \.self) { index in
            Button(action: {
              currentSoalIndex = index
              dismiss()
            }) {
              Text("\(index + 1)")
                .font(.headline)
                .frame(width: 50, height: 50)
                .background(answeredSoalIds.contains(index) ? Color.main.opacity(0.2) : Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(currentSoalIndex == index ? Color.main : Color.clear, lineWidth: 2)
                )
            }
          }
        }
        .padding()
      }
      .navigationTitle("Navigasi Soal")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Tutup") { dismiss() }
        }
      }
    }
  }
}


#Preview {
  TryOutOverviewSheet(totalSoal: 20, answeredSoalIds: [1, 5, 10], currentSoalIndex: .constant(3))
}
