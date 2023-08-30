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

  init(text: String) {
    self.text = text
    self.id = UUID()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
