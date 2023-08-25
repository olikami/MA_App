//
//  SettingsView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct PersonInfoView: View {
  @EnvironmentObject private var model: Model

  var body: some View {
    if let certificate = model.certificate {
      Text(certificate)
    } else {
      Text("Please create your identity.")
    }
  }
}
