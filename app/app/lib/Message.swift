//
//  Message.swift
//  app
//
//  Created by Oliver Kamer on 30.08.23.
//

import Foundation

struct Message: Codable, Hashable {
  let text: String
  let id: UUID
  let signature: String?
  let certificate: String?
  let sent: Date

  init(text: String, signature: String? = nil, certificate: String? = nil) {
    self.text = text
    self.id = UUID()
    self.signature = signature
    self.certificate = certificate
    self.sent = Date()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
