//
//  SearchClassView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct SearchClassView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredClasses: [UkomClass] {
        if searchText.isEmpty {
            return viewModel.ukomClasses
        } else {
            return viewModel.ukomClasses.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.ukomClasses.isEmpty {
                ProgressView()
                    .padding(.top, 50)
            } else {
                if filteredClasses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Tidak ada hasil")
                            .font(.headline)
                        if !searchText.isEmpty {
                            Text("Coba kata kunci lain atau kurangi filter pencarian.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredClasses) { ukomClass in
                            NavigationLink(destination: SearchClassDetailView(classCode: ukomClass.class_code)) {
                                ClassCardView(ukomClass: ukomClass)
                            }
                            .buttonStyle(PlainButtonStyle()) // Removes blue tint from navigation link
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Cari Kelas")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Cari kelas…"
        )
        .onAppear {
            if viewModel.ukomClasses.isEmpty {
                Task {
                    await viewModel.fetchUkomClasses()
                }
            }
        }
    }
}

#Preview {
    SearchClassView()
}
