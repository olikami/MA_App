//
//  CommunityView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct CommunityView: View {
  @EnvironmentObject private var model: Model

  var body: some View {
    if let person = model.person {
      Text("Hello, \(person.name)!")
    } else {
      EmptyView()
    }
  }
}

struct CommunityView_Previews: PreviewProvider {

  static var model = Model()
  static var previews: some View {
    CommunityView().environmentObject(model)
  }
}
