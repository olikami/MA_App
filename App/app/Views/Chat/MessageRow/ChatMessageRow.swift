//
//  ChatMessageRow.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/20/23.
//

import SwiftUI
import X509

struct ChatMessageRow: View {
  @EnvironmentObject private var model: Model
  let message: Message
  let geo: GeometryProxy
  var isCurrentUser: Bool

  var userCertificate: Certificate? {
    guard let certificate_string = message.certificate else {
      return nil
    }
    return getCertificatesFromCertifcateString(certificatestring: certificate_string)[0]
  }

  var bubbleColor: Color {
    guard let certifiate = userCertificate else {
      return Color.red
    }
    let issuerCommonName = getCommonName(subject: certifiate.issuer)

    if issuerCommonName.contains("Official") {
      return Color.blue
    } else if issuerCommonName.contains("Community") {
      return Color.green
    } else {
      return Color.teal
    }
  }

  var body: some View {

    HStack {
      if isCurrentUser {
        Spacer(minLength: geo.size.width * 0.2)
      }
      VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
        if !isCurrentUser {
          if let message_certificate = userCertificate {
            Text(
              getCommonName(
                subject: message_certificate.subject)
            ).font(.caption)
          }
        }
        if !message.content.trimmingCharacters(in: .whitespacesAndNewlines).containsOnlyEmoji {
          Text(message.content)
            .foregroundColor(isCurrentUser ? .primary : .white)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
              isCurrentUser ? Color(hex: 0xe0e0e0) : bubbleColor,
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
