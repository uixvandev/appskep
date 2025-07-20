//
//  UkomClassView.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import SwiftUI

struct UkomClassView: View {
  var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        Text("Kelas UKOM")
          .font(.title)
          .fontWeight(.bold)
        
        Text("Pilih kelas yang sesuai dengan kebutuhan belajar Anda")
          .font(.subheadline)
          .foregroundColor(Color(.neutral10))
          .multilineTextAlignment(.center)
        
        // TODO: Implement class list
        Spacer()
        
        Text("Coming Soon...")
          .font(.headline)
          .foregroundColor(Color(.main))
        Spacer()
      }
      .padding()
      .navigationTitle("Kelas UKOM")
    }
  }
}

#Preview {
  UkomClassView()
}
