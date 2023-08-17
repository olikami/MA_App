//
//  SwiftUIView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct PageOne: View {
  let nextPage: () -> Void
  var body: some View {
    VStack(spacing: 20) {
      Text("Welcome!")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text(
        "Welcome to this application. We need to ask you a bunch of questions about your personal details to get started. All data is treated confidentially."
      )
      .font(.body)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 20)  // Add some horizontal padding for better readability

      Button(action: {
        nextPage()
      }) {
        Text("Let's get started")
          .font(.headline)
          .padding()
          .background(Color.blue)  // Change to your desired color
          .foregroundColor(.white)
          .cornerRadius(8)
      }
      .padding(.bottom, 60)  // Padding from the bottom edge
    }
  }
}
