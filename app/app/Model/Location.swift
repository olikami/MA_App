//
//  Location.swift
//  app
//
//  Created by Oliver Kamer on 29.08.23.
//

import Combine
import SwiftUI

struct Location: Codable, Identifiable, Hashable {
  let url: URL
  let postcode: Int
  let messages: [Message]

  var id: Int {
    return postcode
  }
}
