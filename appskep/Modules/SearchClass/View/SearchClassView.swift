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
            return viewModel.ukomClasses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.ukomClasses.isEmpty {
                ProgressView()
                    .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredClasses) { ukomClass in
                        NavigationLink(destination: SearchClassDetailView(classId: ukomClass.id)) {
                            ClassCardView(ukomClass: ukomClass)
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes blue tint from navigation link
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Cari Kelas")
        .searchable(text: $searchText, prompt: "Search")
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
