//
//  File.swift
//  PeerChat
//
//  Created by Oliver Kamer on 06.07.23.
//

import Foundation
import UIKit

class Model: ObservableObject {
  @Published var nearby: Nearby
  @Published var person: Person

  init() {
    let person = Person(UIDevice.current.name, id: UIDevice.current.identifierForVendor!)
    self.person = person
    self.nearby = Nearby(person: person)
  }
}
