//
//  SettingsView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI
import X509

struct PersonInfoView: View {
  @EnvironmentObject private var model: Model

  private var certificates: [Certificate] {
    model.getCertificates()
  }

  var body: some View {
    if certificates.isEmpty {
      Text("We don't have a certificate yet.")
    } else {
      CertificateView(certificates: certificates)
    }
  }
}
