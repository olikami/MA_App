//
//  ChatMessageRow.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/20/23.
//

import SwiftUI

struct ChatMessageRow: View {
  @EnvironmentObject private var model: Model
  let message: Message
  let geo: GeometryProxy
  var isCurrentUser: Bool

  var body: some View {

    HStack {
      if isCurrentUser {
        Spacer(minLength: geo.size.width * 0.2)
      }
      VStack(alignment: .trailing) {
        if !message.content.trimmingCharacters(in: .whitespacesAndNewlines).containsOnlyEmoji {
          Text(message.content)
            .foregroundColor(isCurrentUser ? .white : .primary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
              isCurrentUser ? .blue : Color(uiColor: .secondarySystemBackground),
              in: RoundedRectangle(cornerRadius: 20.0, style: .continuous))
        } else {
          Text(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
            .font(.system(size: 40))
            .multilineTextAlignment(isCurrentUser ? .trailing : .leading)
            .padding()
        }
        Text(formatDateCompact(date: message.sent)).foregroundColor(Color.gray).font(.footnote)
      }
      if !isCurrentUser {
        Spacer(minLength: geo.size.width * 0.2)
      }
    }
  }
}
