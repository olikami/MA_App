//
//  CommunityView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct CommunityView: View {
  @EnvironmentObject private var model: Model

  func sendMessage(newMessage: String) {
    model.sendCommunityMessage(newMessage: newMessage)
  }

  var body: some View {
    if let location = model.location {
      NavigationView {
        ChatView(messages: model.communityMessages, sendMessage: sendMessage).toolbar {
          ToolbarItem(placement: .principal) {
            VStack {
              Text(postcodeFormatter(location)).font(.headline)
              Text("Coumminity Chat").font(.subheadline)
            }
          }
        }
      }
    } else {
      Text("Please setup your location in the settings.")
    }
  }
}

struct CommunityView_Previews: PreviewProvider {

  static var model = Model()
  static var previews: some View {
    CommunityView().environmentObject(model)
  }
}
