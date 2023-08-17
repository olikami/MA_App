//
//  File.swift
//  PeerChat
//
//  Created by Oliver Kamer on 06.07.23.
//

import Foundation
import UIKit

class Model: ObservableObject {

  @Published var person: Person?
  @Published var nearby: Nearby?

  init() {

  }

  func setNearby(person: Person) {
    self.nearby = Nearby(person: person)
  }
}
