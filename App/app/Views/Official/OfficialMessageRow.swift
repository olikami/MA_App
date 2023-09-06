//
//  OfficialMessageRow.swift
//  app
//
//  Created by Oliver Kamer on 06.09.23.
//

import SwiftUI

struct OfficialMessageRow: View {
  var message: OfficialMessage

  var body: some View {
    VStack(alignment: .leading) {
      Text(message.content)
      HStack {
        Text("Official Message".uppercased()).foregroundColor(Color.gray).font(.caption)
        Spacer()
        Text(formatDateCompact(date: message.sent)).foregroundColor(Color.gray).font(
          .footnote)
      }
      Divider()
    }

  }
}
