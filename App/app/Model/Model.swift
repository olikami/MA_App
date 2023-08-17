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

  init() {

  }

  func setNearby(person: Person) {
    self.nearby = Nearby(person: person)
  }
}

extension Model {
  var needsSetup: Binding<Bool> {
    Binding<Bool>(
      get: { self.person == nil },
      set: { newValue in
        if !newValue {
          self.person = nil
        }
      }
    )
  }
}
