//
//  PembahasanOptionView.swift
//  appskep
//
//  Created by irfan wahendra on 02/08/25.
//

import SwiftUI

struct PembahasanOptionView: View {
    let option: PembahasanOption
    let index: Character
    let isUserAnswer: Bool
    let isCorrectAnswer: Bool
    
    private var backgroundColor: Color {
        if isCorrectAnswer {
            return Color.green.opacity(0.1)
        } else if isUserAnswer && !isCorrectAnswer {
            return Color.red.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isCorrectAnswer {
            return Color.green
        } else if isUserAnswer && !isCorrectAnswer {
            return Color.red
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var indexBackgroundColor: Color {
        if isCorrectAnswer {
            return Color.green
        } else if isUserAnswer && !isCorrectAnswer {
            return Color.red
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var indexTextColor: Color {
        if isCorrectAnswer || (isUserAnswer && !isCorrectAnswer) {
            return Color.white
        } else {
            return Color.primary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Option index with status indicator
            ZStack {
                Text(String(index))
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 24, height: 24)
                    .background(indexBackgroundColor)
                    .foregroundColor(indexTextColor)
                    .clipShape(Circle())
                
                // Status icons
                if isCorrectAnswer {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                        .offset(x: 12, y: -12)
                        .background(Circle().fill(Color.green).frame(width: 16, height: 16))
                } else if isUserAnswer && !isCorrectAnswer {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white)
                        .offset(x: 12, y: -12)
                        .background(Circle().fill(Color.red).frame(width: 16, height: 16))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(option.option_text)
                    .font(.body)
                
                // Status labels
                HStack {
                    if isUserAnswer {
                        Text("Jawaban Anda")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    if isCorrectAnswer {
                        Text("Jawaban Benar")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        PembahasanOptionView(
            option: PembahasanOption(options_id: 1, option_text: "Berikan minum", is_correct: false),
            index: "A",
            isUserAnswer: true,
            isCorrectAnswer: false
        )
        
        PembahasanOptionView(
            option: PembahasanOption(options_id: 2, option_text: "Lakukan RJP", is_correct: true),
            index: "B",
            isUserAnswer: false,
            isCorrectAnswer: true
        )
        
        PembahasanOptionView(
            option: PembahasanOption(options_id: 3, option_text: "Hubungi keluarga", is_correct: false),
            index: "C",
            isUserAnswer: false,
            isCorrectAnswer: false
        )
    }
    .padding()
}
#Preview {
  PembahasanOptionView(option: .init(options_id: 1, option_text: "Asasasas", is_correct: true), index: "A", isUserAnswer: true, isCorrectAnswer: true)
}
