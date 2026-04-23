//
//  TryOutOverviewSheet.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct TryOutOverviewSheet: View {
  let totalSoal: Int
  let answeredSoalIds: Set<String>
  let doubtSoalIds: Set<String>
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
            let isAnswered = answeredSoalIds.contains(soal.question_code)
            let isDoubt = doubtSoalIds.contains(soal.question_code)
            
            Button(action: {
              currentSoalIndex = index
              dismiss()
            }) {
              Text("\(index + 1)")
                .font(.headline)
                .frame(width: 50, height: 50)
                .background(getBackgroundColor(isAnswered: isAnswered, isDoubt: isDoubt, isCurrent: currentSoalIndex == index))
                .foregroundColor((isAnswered && !isDoubt) ? .white : .primary)
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
  
  private func getBackgroundColor(isAnswered: Bool, isDoubt: Bool, isCurrent: Bool) -> Color {
    if isDoubt {
      return .yellow
    }
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
    answeredSoalIds: ["SOAL-001", "SOAL-003"],
    doubtSoalIds: ["SOAL-002"],
    soals: [
      Soal(question_code: "SOAL-001", question: "Test 1", explanation: "Test", pilihan_jawaban: []),
      Soal(question_code: "SOAL-002", question: "Test 2", explanation: "Test", pilihan_jawaban: []),
      Soal(question_code: "SOAL-003", question: "Test 3", explanation: "Test", pilihan_jawaban: []),
      Soal(question_code: "SOAL-004", question: "Test 4", explanation: "Test", pilihan_jawaban: []),
      Soal(question_code: "SOAL-005", question: "Test 5", explanation: "Test", pilihan_jawaban: [])
    ],
    currentSoalIndex: .constant(0)
  )
}
