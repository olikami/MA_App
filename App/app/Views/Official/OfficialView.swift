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
            VStack {
              Text(message.content)
              HStack {
                Spacer()
                Text(formatDateCompact(date: message.sent)).foregroundColor(Color.gray).font(
                  .footnote)
              }

              Divider()
            }
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
