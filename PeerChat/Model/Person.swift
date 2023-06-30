//
//  Person.swift
//  PeerChat
//
//  Created by Oliver Kamer on 30.06.23.
//

import Foundation

struct Person: Codable, Equatable, Hashable {
  var name: String
  let id: UUID

  static func == (lhs: Person, rhs: Person) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }

  init(_ name: String, id: UUID) {
    self.name = name

    self.id = id
  }

  mutating func setName(newName: String) {
    self.name = newName
  }
}
