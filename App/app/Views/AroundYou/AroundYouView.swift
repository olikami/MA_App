//
//  NearbyView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct AroundYouView: View {
  @EnvironmentObject private var model: Model

  func sendMessage(message: String, chat: Chat) {
    model.sendLocalMessage(message, chat: chat)
  }

  var body: some View {
    if (model.person != nil) && model.hasKey && (model.certificate_string != nil) {
      NavigationView {
        List {
          Section("Chats") {
            if model.localChats.isEmpty {
              Text("No Chats")
            } else {
              ForEach(Array(model.localChats), id: \.value.id) { id, chat in

                Text(chat.peer.displayName)
              }
            }
          }
          Section("Near-By Peers") {
            if model.localPeers.isEmpty {
              Text("No Peers")
            } else {
              ForEach(model.localPeers, id: \.hash) { peer in
                Text(peer.displayName)
              }
            }
          }
        }
      }
    } else {
      Text("Setup needed")
    }
  }
}

struct NearbyView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    AroundYouView().environmentObject(model)
  }
}
