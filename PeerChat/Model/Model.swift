//
//  File.swift
//  PeerChat
//
//  Created by Oliver Kamer on 06.07.23.
//

import Foundation
import UIKit

class Model: ObservableObject {

  @Published var person: Person
  @Published var nearby: Nearby?

  init() {
    let person = Person(UIDevice.current.name, id: UIDevice.current.identifierForVendor!)
    self.person = person
  }

  func setNearby(person: Person) {
    self.nearby = Nearby(person: person)
  }
}
