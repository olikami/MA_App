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
      if model.nearby != nil {
        AroundYouView().tabItem {
          Label("Around You", systemImage: "location.circle")
        }
      }
      if model.person != nil {
        CommunityView().tabItem {
          Label("Community", systemImage: "building.columns.fill")
        }
      }
      if model.person != nil {
        OfficialView().tabItem {
          Label("Official", systemImage: "info.circle.fill")
        }
      }
      if model.identity != nil {
        PersonInfoView().tabItem {
          Label("You", systemImage: "person.circle.fill")
        }
      }
      if model.identity != nil && model.person != nil {
        SettingsView().tabItem {
          Label("Settings", systemImage: "gear")
        }
      }
    }.sheet(isPresented: model.needsSetup) {
      SetupView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    ContentView().environmentObject(model)
  }
}
