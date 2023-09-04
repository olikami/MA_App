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
    if let person = model.person {
      ChatView(messages: model.communityMessages, sendMessage: sendMessage)
    } else {
      Text("Setup needed")
    }
  }
}

struct CommunityView_Previews: PreviewProvider {

  static var model = Model()
  static var previews: some View {
    CommunityView().environmentObject(model)
  }
}
