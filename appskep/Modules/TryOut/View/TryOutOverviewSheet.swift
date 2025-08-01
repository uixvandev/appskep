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
  let soals: [Soal] // Add this to get actual soal IDs
  @Binding var currentSoalIndex: Int
  @Environment(\.dismiss) private var dismiss
  
  private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(0..<totalSoal, id: \.self) { index in
            let soal = soals[index]
            let isAnswered = answeredSoalIds.contains(soal.id)
            
            Button(action: {
              currentSoalIndex = index
              dismiss()
            }) {
              Text("\(index + 1)")
                .font(.headline)
                .frame(width: 50, height: 50)
                .background(getBackgroundColor(isAnswered: isAnswered, isCurrent: currentSoalIndex == index))
                .foregroundColor(isAnswered ? .white : .primary)
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
  
  private func getBackgroundColor(isAnswered: Bool, isCurrent: Bool) -> Color {
    if isAnswered {
      return Color.main
    } else {
      return Color(.systemGray6)
    }
  }
}

#Preview {
  TryOutOverviewSheet(
    totalSoal: 5,
    answeredSoalIds: [1, 3],
    soals: [
      Soal(id: 1, question: "Test 1", explanation: "Test", pilihan_jawaban: []),
      Soal(id: 2, question: "Test 2", explanation: "Test", pilihan_jawaban: []),
      Soal(id: 3, question: "Test 3", explanation: "Test", pilihan_jawaban: []),
      Soal(id: 4, question: "Test 4", explanation: "Test", pilihan_jawaban: []),
      Soal(id: 5, question: "Test 5", explanation: "Test", pilihan_jawaban: [])
    ],
    currentSoalIndex: .constant(0)
  )
}
