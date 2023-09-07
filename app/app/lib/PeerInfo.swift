//
//  PeerInfo.swift
//  COMUNI
//
//  Created by Oliver Kamer on 07.09.23.
//

import Foundation

struct PeerInfo: Codable {
  enum PeerInfoType: Codable {
    case Person
  }
  var peerInfoType: PeerInfoType = .Person
}
