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
  @FocusState private var nameIsFocused: Bool

  private var isNameChanged: Bool {
    name != model.person.name
  }

  var body: some View {
    NavigationView {
      List {
        Section("Name") {
          HStack {
            TextField(
              "Name",
              text: $name
            ).focused($nameIsFocused)
            Button {
              model.person.setName(newName: name)
              nameIsFocused = false
            } label: {
              Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)
                .opacity(isNameChanged ? 1 : 0).animation(.spring(), value: isNameChanged)
            }
            .frame(maxWidth: isNameChanged ? nil : 0)
            .animation(.spring(), value: isNameChanged)

          }
        }
      }
    }.onAppear {
      self.name = model.person.name
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var model = Model()

  static var previews: some View {
    SettingsView().environmentObject(model)
  }
}