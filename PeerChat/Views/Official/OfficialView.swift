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
    Text("Hello, \(model.myPerson.name)!")
  }
}

struct OfficialView_Previews: PreviewProvider {
  static var previews: some View {
    OfficialView()
  }
}
