//
//  ContentView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/18/23.
//

import SwiftUI

struct ContentView: View {

  @EnvironmentObject private var model: Model

  var body: some View {
    TabView {
      NearbyView().tabItem {
        Label("Around You", systemImage: "location.circle")
      }
      CommunityView().tabItem {
        Label("Community", systemImage: "building.columns.fill")
      }
      OfficialView().tabItem {
        Label("Official", systemImage: "info.circle.fill")
      }
      SettingsView().tabItem {
        Label("Settings", systemImage: "gearshape.fill")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    ContentView().environmentObject(model)
  }
}
