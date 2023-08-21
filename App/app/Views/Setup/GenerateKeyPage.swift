//
//  GenerateKeyPage.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct GenerateKeyPage: View {
  let nextPage: () -> Void
  @EnvironmentObject var model: Model
  @State private var isProcessing = false

  var body: some View {
    VStack(spacing: 20) {
      Text("Generate Your Private Key")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 40)

      // Display the appropriate message depending on whether the key is generated
      if !(model.identity?.hasKey() ?? false) {
        Text("By pressing the button below, a private key will be generated for you.")
          .font(.body)
          .multilineTextAlignment(.center)
          .padding()
      } else {
        Text("Your key has been generated. Below you can see the fingerprint of your public key:")
          .font(.body)
          .multilineTextAlignment(.center)
          .padding()
      }

      // Conditionally display the Generate Key button
      if !(model.identity?.hasKey() ?? false) && !isProcessing {
        Button(action: {
          withAnimation {
            isProcessing = true
          }
          DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
              model.createIdentity()
              model.generateKey()
              withAnimation {
                isProcessing = false
              }
            }
          }
        }) {
          Text((isProcessing ? "Generating key..." : "Generate Key"))
            .font(.headline)
            .padding()
            .background((isProcessing ? Color.gray : Color.blue))
            .foregroundColor(.white)
            .cornerRadius(8)
        }.disabled(isProcessing)
      }

      // If the key is generated, display the fingerprint
      if let fingerprint = model.identity?.fingerprint() {
        Text(fingerprint)
          .font(.body)
          .foregroundColor(.gray)
      }

      // Conditionally display the Next button
      if model.identity?.hasKey() ?? false {
        Button(action: {
          nextPage()
        }) {
          Text("Next")
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
      }
    }
    .padding(.horizontal, 50)
  }
}
