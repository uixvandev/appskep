//
//  MyClassView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct MyClassView: View {
    @StateObject private var viewModel = MyClassViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.myPaidClasses.isEmpty {
                    ProgressView()
                } else if !viewModel.myPaidClasses.isEmpty {
                    List(viewModel.myPaidClasses) { order in
                      NavigationLink(destination: MyClassDetailView(order: order)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(order.kelas.name)
                                    .font(.headline)
                                Text(order.kelas.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } else {
                    Text("Anda belum memiliki kelas.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Kelas Saya")
            .onAppear {
                if viewModel.myPaidClasses.isEmpty {
                    Task {
                        await viewModel.fetchMyClasses()
                    }
                }
            }
        }
    }
}

#Preview {
    MyClassView()
}
