//
//  TryOutInfoSheet.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct TryOutInfoSheet: View {
  let paket: Paket
  let orderId: Int
  
  @StateObject private var viewModel = TryOutViewModel()
  @EnvironmentObject private var tryOutCoordinator: TryOutCoordinator
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(spacing: 20) {
      Text(paket.name)
        .font(.title2)
        .fontWeight(.bold)
      
      prosedurSection
      
      Divider()
      
      infoRow(label: "Waktu pengerjaan:", value: "\(paket.duration) menit")
      infoRow(label: "Jumlah soal:", value: "50 Soal") // Asumsi, bisa disesuaikan
      
      Spacer()
      
      if viewModel.isLoading {
        ProgressView()
      } else {
        Button {
          Task {
            let success = await viewModel.startTryOut(orderId: orderId, paketId: paket.id)
            if success, let sessionId = viewModel.tryOutSession?.id {
              dismiss() // Dismiss sheet first
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tryOutCoordinator.startTryOut(tryOutId: sessionId)
              }
            }
          }
        } label: {
          CustomLongButton(title: "Mulai Try Out", titleColor: .white, bgButtonColor: .main)
        }
      }
    }
    .padding()
    .navigationTitle("Detail Paket")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private var prosedurSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Prosedur Try Out")
        .font(.headline)
      Text("1. Pastikan koneksi internet stabil\n2. Klik Tombol Mulai Try Out untuk memulai\n3. Pilih jawaban dengan klik pada button jawaban yang dipilih\n4. Berpindah soal dapat dilakukan dengan klik pada tombol Sebelumnya atau Selanjutnya, atau juga bisa dengan klik nomor soal pada Overview Jawaban\n5. Jawaban yang sudah dipilih akan langsung tersimpan di sistem selagi tidak ada gangguan jaringan\n6. Timer tidak dapat dihentikan atau dijeda\n7. Jika sudah selesai mengerjakan, klik selesaikan try out\n8. **PENTING: Halaman try out akan fullscreen dan tidak dapat keluar sampai selesai**")
        .font(.caption)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private func infoRow(label: String, value: String) -> some View {
    HStack {
      Text(label)
      Spacer()
      Text(value).fontWeight(.bold)
    }
  }
}

#Preview {
  TryOutInfoSheet(paket: Paket(id: 1, name: "Ass", description: "asasa", duration: 10), orderId: 1)
}
