//
//  MyClassDetailView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct MyClassDetailView: View {
  let order: MyOrder
  @StateObject private var viewModel = SearchClassDetailViewModel()
  @State private var selectedPaket: Paket?
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(order.kelas.name)
          .font(.title)
          .fontWeight(.bold)
        
        Text(order.kelas.description)
          .font(.body)
          .foregroundColor(.secondary)
        
        Divider()
        
        Text("Paket Try Out Tersedia")
          .font(.headline)
        
        if viewModel.isLoading {
          ProgressView()
        } else {
          ForEach(viewModel.pakets) { paket in
            NavigationLink(destination: TryOutInfoSheet(paket: paket, orderId: order.id)) {
              PaketRowView(paket: paket)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
      .padding()
    }
    .navigationTitle("Detail Kelas Saya")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        await viewModel.fetchAllDetails(id: order.kelas.id)
      }
    }
    .sheet(item: $selectedPaket) { paket in
      NavigationStack {
        TryOutInfoSheet(paket: paket, orderId: order.id)
      }
    }
  }
}

#Preview {
  MyClassDetailView(order: MyOrder(id: 1, status: "paid", kelas: .init(id: 1, name: "Test", description: "Test", price: 1000)))
}
