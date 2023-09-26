//
//  GetCertificatePage.swift
//  app
//
//  Created by Oliver Kamer on 18.08.23.
//

import SwiftUI

struct ShowCertificate: View {
  @EnvironmentObject var model: Model

  var body: some View {
    Text(
      "Waiting for your certifcate, as soon as it has been generated you will be able to use the app."
    )
  }
}
