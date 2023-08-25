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
    if model.getCertificates()?.count ?? 0 > 0 {
      Text((model.getCertificates()?[0].subject.description)!)
    } else {
      Text("We don't have a certificate yet.")
    }
  }
}
