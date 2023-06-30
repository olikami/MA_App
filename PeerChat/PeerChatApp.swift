//
//  PeerChatApp.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/18/23.
//

import SwiftUI

@main
struct PeerChatApp: App {
  @ObservedObject private var model = Model()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(model)

    }
  }
}
