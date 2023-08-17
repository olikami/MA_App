//
//  SetupView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct SetupView: View {
  @State private var selectedPage = 1
  private var maxPages = 3

  func nextPage() {
    withAnimation { selectedPage += 1 }
  }

  var body: some View {
    TabView(selection: $selectedPage) {
      PageOne(nextPage: nextPage).tag(1)
      PageTwo(nextPage: nextPage).tag(2)
      PageThree().tag(3)
    }
    .tabViewStyle(PageTabViewStyle())
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
  }
}

struct SetupView_Previews: PreviewProvider {
  static var model = Model()

  static var previews: some View {
    SetupView().environmentObject(model)
  }
}
