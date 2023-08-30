//
//  NearbyView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 29.06.23.
//

import SwiftUI

struct AroundYouView: View {
  @EnvironmentObject private var model: Model

  var body: some View {

    Text("Setup needed")
  }
}

struct NearbyView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    AroundYouView().environmentObject(model)
  }
}
