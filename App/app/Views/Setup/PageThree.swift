//
//  PageThree.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import SwiftUI

struct PageThree: View {
  @EnvironmentObject private var model: Model
  var body: some View {
    if let person = model.person {
      Text("Hello, \(person.name)")
    } else {
      EmptyView()
    }
  }
}

struct PageThree_Previews: PreviewProvider {
  static var previews: some View {
    PageThree()
  }
}
