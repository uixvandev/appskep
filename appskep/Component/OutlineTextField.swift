//
//  OutlineTextField.swift
//  Appskep Apps
//
//  Created by irfan wahendra on 01/05/25.
//

import SwiftUI

struct OutlineTextField: View {
    enum FieldType {
        case text, secure
    }

    @Binding var text: String
    var placeholder: String
    var fieldType: FieldType = .text
    var validation: ((String) -> String?)? = nil

    @FocusState private var isFocused: Bool
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            inputField
                .focused($isFocused)
                .padding()
                .background(Color.white)
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 5)
            }
        }
        .onChange(of: text) {
            validate()
        }
        .onChange(of: isFocused) { _, newValue in
            if !newValue {
                validate()
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        switch fieldType {
        case .text:
            TextField(placeholder, text: $text)
        case .secure:
            SecureField(placeholder, text: $text)
        }
    }

    private var borderColor: Color {
        if error != nil { return .red }
      return isFocused ? .focus : .neutral80
    }

    private func validate() {
        if let validation {
            error = validation(text)
        }
    }
}



#Preview {
    StatefulPreviewWrapper("") { binding in
        VStack(spacing: 30) {
            OutlineTextField(
                text: binding,
                placeholder: "Email",
                fieldType: .text,
                validation: { $0.isEmpty ? "Email harus diisi" : nil }
            )

            OutlineTextField(
                text: binding,
                placeholder: "Password",
                fieldType: .secure,
                validation: { $0.count < 6 ? "Minimal 6 karakter" : nil }
            )
        }
        .padding()
    }
}


struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ initialValue: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}


