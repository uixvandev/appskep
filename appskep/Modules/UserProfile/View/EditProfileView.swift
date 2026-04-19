//
//  EditProfileView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct EditProfileView: View {
  @EnvironmentObject var authManager: AuthManager
  @StateObject private var viewModel = EditProfileViewModel()
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          // Profile fields
          profileFields
        }
        .padding()
      }
      .navigationTitle("Profil")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Kembali") {
            dismiss()
          }
          .foregroundColor(.main)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Simpan") {
            Task {
              await viewModel.updateProfile()
              if viewModel.isUpdateSuccessful {
                dismiss()
              }
            }
          }
          .foregroundColor(.main)
          .disabled(viewModel.isLoading)
        }
      }
      .background(Color(.systemGray6).ignoresSafeArea())
      .onAppear {
        viewModel.loadCurrentUserData(authManager.currentUser)
      }
      .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
        Button("OK") {
          viewModel.clearError()
        }
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
      .overlay {
        if viewModel.isLoading {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
          
          VStack {
            ProgressView()
            Text("Menyimpan...")
              .font(.headline)
              .padding(.top)
          }
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(16)
        }
      }
    }
  }
  
  private var profileFields: some View {
    VStack(spacing: 16) {
      ProfileTextField(
        title: "Nama",
        text: $viewModel.name,
        placeholder: "Irfan Wahendra"
      )
      
      ProfileTextField(
        title: "Email",
        text: $viewModel.email,  // Now editable instead of readonly
        placeholder: "irfanwahendra.mail@gmail.com",
        keyboardType: .emailAddress
      )
      
      ProfileTextField(
        title: "No. Telepon",
        text: $viewModel.phoneNumber,
        placeholder: "082388847382",
        keyboardType: .phonePad
      )
      
      ProfileTextField(
        title: "Jenis kelamin",
        text: $viewModel.gender,
        placeholder: "Pilih jenis kelamin",
        isPickerField: true,
        pickerOptions: ["male", "female"],  // API values
        pickerDisplayMap: [
          "male": "Laki-laki",
          "female": "Perempuan"
        ]
      )
      
      ProfileDateField(
        title: "Tanggal Lahir",
        date: $viewModel.birthDate
      )
      
      ProfileTextField(
        title: "Institusi",
        text: $viewModel.institution,
        placeholder: "Nama Institusi"
      )
      
      ProfileTextField(
        title: "Profesi",
        text: $viewModel.profession,
        placeholder: "Profesi Anda"
      )
      
      ProfileTextField(
        title: "Alamat",
        text: $viewModel.address,
        placeholder: "Alamat Lengkap",
        isMultiline: true
      )
      
      ProfileTextField(
        title: "Kota",
        text: $viewModel.city,
        placeholder: "Nama Kota"
      )
      
      ProfileTextField(
        title: "Provinsi",
        text: $viewModel.province,
        placeholder: "Nama Provinsi"
      )
      
    }
  }
}

// MARK: - Supporting Views
struct ProfileTextField: View {
  let title: String
  @Binding var text: String
  let placeholder: String
  var isDisabled: Bool = false
  var isMultiline: Bool = false
  var keyboardType: UIKeyboardType = .default
  var isPickerField: Bool = false
  var pickerOptions: [String] = []
  var pickerDisplayMap: [String: String] = [:]
  
  @State private var showPicker = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      if isMultiline {
        TextEditor(text: $text)
          .frame(minHeight: 80)
          .padding(12)
          .background(Color(.systemBackground))
          .cornerRadius(12)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color(.systemGray4), lineWidth: 1)
          )
          .disabled(isDisabled)
      } else if isPickerField {
        Button(action: {
          showPicker = true
        }) {
          HStack {
            Text(text.isEmpty ? placeholder : (pickerDisplayMap[text] ?? text))
              .foregroundColor(text.isEmpty ? .secondary : .primary)
            Spacer()
            Image(systemName: "chevron.down")
              .foregroundColor(.secondary)
          }
          .padding(12)
          .background(Color(.systemBackground))
          .cornerRadius(12)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color(.systemGray4), lineWidth: 1)
          )
        }
        .disabled(isDisabled)
        .confirmationDialog("Pilih \(title)", isPresented: $showPicker) {
          ForEach(pickerOptions, id: \.self) { option in
            Button(pickerDisplayMap[option] ?? option) {
              text = option
            }
          }
          Button("Batal", role: .cancel) { }
        }
      } else {
        TextField(placeholder, text: $text)
          .keyboardType(keyboardType)
          .textInputAutocapitalization(.words)
          .padding(12)
          .background(isDisabled ? Color(.systemGray6) : Color(.systemBackground))
          .cornerRadius(12)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color(.systemGray4), lineWidth: 1)
          )
          .disabled(isDisabled)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct ProfileDateField: View {
  let title: String
  @Binding var date: Date
  
  @State private var showDatePicker = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Button(action: {
        showDatePicker = true
      }) {
        HStack {
          Text(formatDate(date))
            .foregroundColor(.primary)
          Spacer()
          Image(systemName: "calendar")
            .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color(.systemGray4), lineWidth: 1)
        )
      }
      .sheet(isPresented: $showDatePicker) {
        NavigationStack {
          DatePicker(
            "Pilih Tanggal",
            selection: $date,
            displayedComponents: .date
          )
          .datePickerStyle(.wheel)
          .padding()
          .navigationTitle("Tanggal Lahir")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button("Selesai") {
                showDatePicker = false
              }
            }
          }
        }
        .presentationDetents([.medium])
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.locale = Locale(identifier: "id_ID")
    return formatter.string(from: date)
  }
}

#Preview {
  EditProfileView()
    .environmentObject(AuthManager.shared)
}
