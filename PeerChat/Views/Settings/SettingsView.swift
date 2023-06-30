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
    name != model.myPerson.name
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
              model.setName(newName: name)
              nameIsFocused = false
            } label: {
              Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)
                .opacity(isNameChanged ? 1 : 0).animation(.spring(), value: name)
            }
            .frame(maxWidth: isNameChanged ? nil : 0)
            .animation(.spring(), value: name)

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
