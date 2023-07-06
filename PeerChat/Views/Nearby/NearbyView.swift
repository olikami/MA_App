//
//  NearbyView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct NearbyView: View {
  @EnvironmentObject private var model: Model

  var body: some View {
    NavigationView {
      if let nearby = model.nearby {
        List {
          Section("Chats") {
            if nearby.chats.isEmpty {
              Text("No Chats")
            } else {
              ForEach(Array(nearby.chats), id: \.value.id) { id, chat in
                NavigationLink {
                  ChatView(person: id)
                    .navigationTitle(chat.person.name)
                } label: {
                  Text(chat.peer.displayName)
                }
              }
            }
          }
          Section("Near-By Peers") {
            if nearby.connectedPeers.isEmpty {
              Text("No Peers")
            } else {
              ForEach(nearby.connectedPeers, id: \.hash) { peer in
                Text(peer.displayName)
              }
            }
          }
          Section("You") {
            Text("\(nearby.myPerson.name)")
          }
        }
      }
    }
  }
}

struct NearbyView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    NearbyView().environmentObject(model)
  }
}
