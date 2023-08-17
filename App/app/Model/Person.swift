//
//  Person.swift
//  PeerChat
//
//  Created by Oliver Kamer on 30.06.23.
//

import Foundation

class Person: ObservableObject, Codable, Equatable, Hashable {
  @Published var name: String
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

  func setName(newName: String) {
    self.name = newName
  }

  // Codable conformance
  enum CodingKeys: CodingKey {
    case name, id
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    id = try container.decode(UUID.self, forKey: .id)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(id, forKey: .id)
  }
}
