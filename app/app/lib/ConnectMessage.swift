//
//  ConnectMessage.swift
//  COMUNI
//
//  Created by Oliver Kamer on 07.09.23.
//

import Foundation

struct ConnectMessage: Codable {
  enum MessageType: Codable {
    case Message
    case PeerInfo
  }

  var messageType: MessageType = .Message
  var peerInfo: Person? = nil
  var message: Message? = nil

}
