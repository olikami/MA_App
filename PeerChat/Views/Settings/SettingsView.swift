//
//  SettingsView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct SettingsView: View {

  @EnvironmentObject private var model: Model
  @State private var name: String = ""

  var body: some View {
    NavigationView {
      List {
        Section("Name") {
          TextField(
            "Name",
            text: $name
          ).onChange(of: name) { newValue in
            model.setName(newName: newValue)
          }
        }
      }
    }.onAppear {
      self.name = model.myPerson.name
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var model = Model()

  static var previews: some View {
    SettingsView().environmentObject(model)
  }
}
