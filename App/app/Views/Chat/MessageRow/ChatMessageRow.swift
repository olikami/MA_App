//
//  ChatMessageRow.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/20/23.
//

import Security
import SwiftASN1
import SwiftUI
import X509

struct ChatMessageRow: View {
  @EnvironmentObject private var model: Model
  let message: Message
  let geo: GeometryProxy
  var isCurrentUser: Bool

  @State var showMessageInfo: Bool = false

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
      }.contentShape(Rectangle())
        .onTapGesture {
          showMessageInfo = true
        }
      if !isCurrentUser {
        Spacer(minLength: geo.size.width * 0.2)
      }
    }.sheet(isPresented: $showMessageInfo) {
      ChatMessageInfoView(message: message, isCurrentUser: isCurrentUser)
    }
  }
}

struct ChatMessageInfoView: View {

  let message: Message
  let isCurrentUser: Bool
  @State private var signatureString: String = "Signature verification failed"

  var body: some View {
    VStack(alignment: .leading) {
      GeometryReader { geometry in
        ChatMessageRow(message: message, geo: geometry, isCurrentUser: isCurrentUser)
      }

      Spacer()
      if let certificatesString = message.certificate {
        let certificates = getCertificatesFromCertifcateString(
          certificatestring: certificatesString)
        let author = getCommonName(subject: certificates[0].subject)
        let role = String(
          getCommonName(subject: certificates[0].issuer).split(separator: " ").first ?? "")

        Text("Author: \(author)")
        Text("Timestamp: \(formatDateCompact(date: message.sent))")
        Text("Signature: \(signatureString)")
        Text("Role: \(role)")

        Spacer()
        HStack {
          Spacer()
          CertificateView(certificates: certificates)
          Spacer()
        }

      }
      Spacer()
    }
    .onAppear(perform: verifySignature)
    .padding()
  }

  func verifySignature() {
    if let certificatesString = message.certificate {
      let certificates = getCertificatesFromCertifcateString(certificatestring: certificatesString)

      do {
        var serializer = DER.Serializer()
        try serializer.serialize(certificates[0])
        let serializerData = Data(serializer.serializedBytes)
        let secCertificate = SecCertificateCreateWithData(nil, serializerData as CFData)
        guard let pubKey = SecCertificateCopyKey(secCertificate!) else { return }
        if let signatureData = Data(base64Encoded: message.signature!) {
          let messageData = message.content.data(using: .utf8)

          var error: Unmanaged<CFError>?
          let signatureVerified = SecKeyVerifySignature(
            pubKey,
            .rsaSignatureDigestPKCS1v15SHA512,
            messageData! as CFData,
            signatureData as CFData,
            &error)

          if signatureVerified {
            signatureString = "Signature successfully verified.)"
          }
        }
      } catch let error {
        print(error)
      }
    }
  }
}
