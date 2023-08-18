//
//  SetupView.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct SetupView: View {
  @State private var selectedPage = 1
  private var maxPages = 6

  func nextPage() {
    if (selectedPage) < maxPages {
      withAnimation { selectedPage += 1 }
    }
  }

  var body: some View {
    TabView(selection: $selectedPage) {
      WelcomePage(nextPage: nextPage).tag(1)
      NamePage(nextPage: nextPage).tag(2)
      ConfirmName(nextPage: nextPage).tag(3)
      GenerateKeyPage(nextPage: nextPage).tag(4)
      GenerateCSRPage(nextPage: nextPage).tag(5)
      GetCertificatePage().tag(6)
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
