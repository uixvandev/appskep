//
//  AnswerOptionsView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct AnswerOptionView: View {
    let option: PilihanJawaban
    let index: Character
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(String(index))
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 24, height: 24)
                .background(isSelected ? Color.main : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle())
            
            Text(option.option_text)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.main : Color.gray.opacity(0.3), lineWidth: 1.5)
        )
    }
}

#Preview {
  AnswerOptionView(option: PilihanJawaban(options_id: 1, question_code: "SOAL-001", option_text: "Assaa", is_correct: true), index: "A", isSelected: true)
}
