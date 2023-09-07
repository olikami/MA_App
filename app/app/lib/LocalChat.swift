//
//  LocalChat.swift
//  COMUNI
//
//  Created by Oliver Kamer on 07.09.23.
//

import Foundation
import MultipeerConnectivity

struct Chat: Equatable {
  static func == (lhs: Chat, rhs: Chat) -> Bool {
    return lhs.id == rhs.id
  }

  var messages: [Message] = []
  var peer: MCPeerID
  var person: Person
  var id = UUID()

}
