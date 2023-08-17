//
//  TextFieldStyles.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/20/23.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(10)
      .background(Color.gray.opacity(0.2))
      .cornerRadius(8)
      .foregroundColor(.primary)
  }
}
