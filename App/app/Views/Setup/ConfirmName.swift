//
//  PageThree.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct ConfirmName: View {
  let nextPage: () -> Void
  @EnvironmentObject private var model: Model

  var body: some View {
    if let person = model.person {
      VStack(spacing: 20) {
        // Display the person's name as a title.

        Text("Hi, \(person.name)")
          .font(.largeTitle)
          .fontWeight(.bold)

        // Display additional information below.
        Text(
          "Next we are going to create a digital identity for you which you'll use to prove your identity towards other people. This requires us to generate a key and a certificate for you."
        )
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()

        // Add a button for the next page.
        Button(action: {
          nextPage()
        }) {
          Text("Okay, let's go")
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
      }
      .padding(.horizontal, 20)
    } else {
      Text("You need to complete the previous pages first!")
    }
  }
}
