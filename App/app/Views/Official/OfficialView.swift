//
//  OfficialView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct OfficialView: View {
  @EnvironmentObject private var model: Model

  var body: some View {
    if let person = model.person {
      Text(person.name)
    } else {
      Text("Please create your person.")
    }
  }
}
