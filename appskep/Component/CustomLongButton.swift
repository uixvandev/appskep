//
//  CustomLongButton.swift
//  Appskep Apps
//
//  Created by irfan wahendra on 29/04/25.
//

import SwiftUI

struct CustomLongButton: View {
  let title: String
  let titleColor: Color
  let bgButtonColor: Color
  
  
  
  var body: some View {
    Text(title)
      .font(.body)
      .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
      .foregroundStyle(titleColor)
      .padding()
      .frame(maxWidth: .infinity, maxHeight: 56)
      .background{
        RoundedRectangle(cornerRadius: 16)
          .foregroundStyle(bgButtonColor)
      }
  }
}

#Preview {
  CustomLongButton(title: "Sign Up", titleColor: Color .white, bgButtonColor: Color.main)
}
