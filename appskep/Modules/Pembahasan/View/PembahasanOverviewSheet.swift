//
//  PembahasanOverviewSheet.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct PembahasanOverviewSheet: View {
    let questions: [PembahasanQuestion]
    @Binding var currentQuestionIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        Button(action: {
                            currentQuestionIndex = index
                            dismiss()
                        }) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .frame(width: 50, height: 50)
                                .background(getBackgroundColor(for: question, isCurrent: currentQuestionIndex == index))
                                .foregroundColor(getTextColor(for: question, isCurrent: currentQuestionIndex == index))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentQuestionIndex == index ? Color.main : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Navigasi Pembahasan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
    
    private func getBackgroundColor(for question: PembahasanQuestion, isCurrent: Bool) -> Color {
        if question.is_user_correct {
            return Color.green.opacity(0.8)
        } else {
            return Color.red.opacity(0.8)
        }
    }
    
    private func getTextColor(for question: PembahasanQuestion, isCurrent: Bool) -> Color {
        return .white
    }
}

#Preview {
    PembahasanOverviewSheet(
        questions: [
            PembahasanQuestion(
                soal_id: 1,
                question: "Test 1",
                user_answer: UserAnswer(pilihan_jawaban_id: 1, option_text: "A", is_correct: true),
                correct_answer: CorrectAnswer(pilihan_jawaban_id: 1, option_text: "A", is_correct: true),
                all_options: [],
                explanation: "Test",
                is_user_correct: true,
                category: "General"
            )
        ],
        currentQuestionIndex: .constant(0)
    )
}
