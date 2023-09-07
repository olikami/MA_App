//
//  Message.swift
//  app
//
//  Created by Oliver Kamer on 30.08.23.
//

import Foundation

struct Message: Codable, Hashable {
  let content: String
  let id: UUID
  let signature: String?
  let certificate: String?
  let sent: Date
  let location: Int?
  let from: Person?

  init(
    text: String, signature: String? = nil, certificate: String? = nil, location: Int? = nil,
    from: Person? = nil
  ) {
    self.content = text
    self.id = UUID()
    self.signature = signature
    self.certificate = certificate
    self.sent = Date()
    self.location = location
    self.from = from
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
