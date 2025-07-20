//
//  ClassCardView.swift
//  appskep
//
//  Created by irfan wahendra on 19/07/25.
//

import SwiftUI

struct ClassCardView: View {
    let ukomClass: UkomClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundColor(.main)
                .padding(10)
                .background(Color.main.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Spacer()

            Text(ukomClass.name)
                .font(.headline)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(ukomClass.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()

            Text("Rp \(ukomClass.price.formatted(.number))")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
  ClassCardView(ukomClass: UkomClass(id: 1, name: "Kelas Try Out SwiftUI", description: "ASdjahjdhajhdjadsaj sdsasds sdhsdhs dahsdhshds ahshd", price: 1222))
}
