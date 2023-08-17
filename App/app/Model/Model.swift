//
//  File.swift
//  PeerChat
//
//  Created by Oliver Kamer on 06.07.23.
//

import Foundation
import SwiftUI
import UIKit

class Model: ObservableObject {

  @Published var person: Person?
  @Published var nearby: Nearby?
  @Published var identity: Identity?
  @Published var setupDone: Bool

  init() {
    self.setupDone = false
  }

  func createPerson(name: String) {
    self.person = Person(name, id: UUID())
  }

  func setNearby(person: Person) {
    self.nearby = Nearby(person: person)
  }

  func createIdentity() {
    self.identity = Identity()
  }

  func generateKey() {
    self.identity?.generatePrivateKey()
  }

  func setupIsDone() {
    self.setupDone = true
  }
}

extension Model {
  var needsSetup: Binding<Bool> {
    Binding<Bool>(
      get: { self.setupDone == false },
      set: { newValue in
        if !newValue {
          self.person = nil
        }
      }
    )
  }
}
