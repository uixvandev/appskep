//
//  SearchClassDetailView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct SearchClassDetailView: View {
  let classId: Int
  @StateObject private var viewModel = SearchClassDetailViewModel()
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    ZStack(alignment: .bottom) {
      if viewModel.isLoading {
        ProgressView()
      } else if let ukomClass = viewModel.ukomClass {
        ScrollView {
          VStack(spacing: 24) {
            // Header
            Image(systemName: "book.closed.fill")
              .font(.system(size: 60))
              .foregroundColor(.main)
              .padding(25)
              .background(Color.main.opacity(0.1))
              .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Class Info
            VStack(spacing: 8) {
              Text(ukomClass.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
              Text(ukomClass.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            
            // Paket List
            VStack(alignment: .leading, spacing: 16) {
              Text("Materi Try Out")
                .font(.headline)
              
              ForEach(viewModel.pakets) { paket in
                PaketRowView(paket: paket)
              }
            }
            
            // Spacer to push content above the button
            Spacer(minLength: 100)
          }
          .padding()
        }
        
        // Floating Button
        Button{
          Task { await viewModel.buyClass(classId: ukomClass.id)}
        } label: {
          CustomLongButton(title: "Beli kelas Rp \(ukomClass.price.formatted(.number))", titleColor: .white, bgButtonColor: .main)
        }
        .padding()
        
      } else if let errorMessage = viewModel.errorMessage {
        Text("Error: \(errorMessage)")
      }
    }
    .navigationTitle("Detail Kelas")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: { dismiss() }) {
          Image(systemName: "chevron.left")
          Text("Kembali")
        }
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchAllDetails(id: classId)
      }
    }
    .alert(isPresented: $viewModel.showOrderAlert) {
      Alert(title: Text("Gagal"), message: Text(viewModel.orderError ?? "Terjadi kesalahan"), dismissButton: .default(Text("OK")))
    }
    .sheet(isPresented: $viewModel.showWebView) {
      if let url = viewModel.redirectURL {
        SafariView(url: url)
      }
    }
  }
}

struct PaketRowView: View {
  let paket: Paket
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(paket.name)
        .font(.headline)
      HStack {
        Text("\(paket.duration) menit") // Assuming 50 questions, adjust as needed
          .font(.subheadline)
          .foregroundColor(.secondary)
        Text("•")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Text("\(paket.totalQuestions ?? 0) soal")
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  NavigationView {
    SearchClassDetailView(classId: 1)
  }
}
