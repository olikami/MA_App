//
//  GenerateCSRPage.swift
//  app
//
//  Created by Oliver Kamer on 18.08.23.
//

import SwiftUI

struct GenerateCSRPage: View {
  let nextPage: () -> Void
  @EnvironmentObject var model: Model
  @State private var isProcessing = false

  var body: some View {
    if let identity = model.identity, let person = model.person, identity.hasKey() {

      VStack(spacing: 20) {
        Text("Request a certificate")
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.top, 40)

        Text(
          "You will now request a certificate. This certificate includes your name and the private part of your key."
        )
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()

        Button(action: {
          withAnimation {
            isProcessing = true
          }
          DispatchQueue.global().async {
            identity.generateCSR(name: person.name)
            sleep(1)
            DispatchQueue.main.async {
              nextPage()
            }
          }

        }) {
          Text((isProcessing ? "Requesting certificate" : "Request certificate"))
            .font(.headline)
            .padding()
            .background((isProcessing ? Color.gray : Color.blue))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
      }
      .padding(.horizontal, 50)
    } else {
      Text("Please first complete the previous steps.")
    }
  }

}
