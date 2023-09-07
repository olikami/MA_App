//
//  ContentView.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/18/23.
//

import SwiftUI

struct ContentView: View {

  @EnvironmentObject private var model: Model

  var isSetupViewPresented: Binding<Bool> {
    Binding<Bool>(
      get: { !self.model.setupDone },
      set: { newValue in self.model.setupDone = !newValue }
    )
  }

  var body: some View {
    TabView {
      AroundYouView().tabItem {
        Label("Around You", systemImage: "location.circle")
      }
      CommunityView().tabItem {
        Label("Community", systemImage: "building.columns.fill")
      }
      OfficialView().tabItem {
        Label("Official", systemImage: "info.circle.fill")
      }

      PersonInfoView().tabItem {
        Label("You", systemImage: "person.circle.fill")
      }

      LocationSettingsView().tabItem {
        Label("Settings", systemImage: "gear")
      }

    }.sheet(isPresented: isSetupViewPresented) {
      SetupView().interactiveDismissDisabled(true)
    }
  }
}

struct ContentView_Previews: PreviewProvider {

  static var model = Model()

  static var previews: some View {
    ContentView().environmentObject(model)
  }
}
