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
    Text(model.identity?.csr ?? "No CSR").textSelection(.enabled)
  }
}
