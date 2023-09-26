//
//  OfficialMessage.swift
//  app
//
//  Created by Oliver Kamer on 05.09.23.
//

import Foundation

struct OfficialMessage: Codable {
  let id: String
  let content: String
  let sent: Date
  let signature: String
  let certificate: String
  let locations: [Int]
}
