//
//  OfficialView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct OfficialView: View {
  @EnvironmentObject private var model: Model

  var body: some View {
    if let location = model.location {
      NavigationView {
        VStack {
          ForEach(model.officialMessages, id: \.id) { message in
            OfficialMessageRow(message: message)
          }
        }
        .padding()
        .toolbar {
          ToolbarItem(placement: .principal) {
            VStack {
              Text(postcodeFormatter(location)).font(.headline)
              Text("Official Messages").font(.subheadline)
            }
          }
        }
        .onAppear {
          model.startFetchingOfficialMessages()
        }
      }
    } else {
      Text("Please set your location in the settings.")
    }
  }
}
