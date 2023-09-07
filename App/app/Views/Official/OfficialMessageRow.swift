//
//  OfficialMessageRow.swift
//  app
//
//  Created by Oliver Kamer on 06.09.23.
//

import SwiftASN1
import SwiftUI
import X509

struct OfficialMessageRow: View {
  var message: OfficialMessage

  @State var showMessageInfo: Bool = false

  var body: some View {
    VStack(alignment: .leading) {
      Text(message.content)
      HStack {
        let role = String(
          getCommonName(
            subject: getCertificatesFromCertifcateString(
              certificatestring: message.certificate)[0].issuer
          ).split(separator: " ").first ?? "")
        if role == "Official" {
          Text("Official Message".uppercased()).foregroundColor(Color.gray).font(.caption)
        } else {
          Text("Check integrity".uppercased()).foregroundColor(Color.gray).font(.caption)
        }
        Spacer()
        Text(formatDateCompact(date: message.sent)).foregroundColor(Color.gray).font(
          .footnote)
      }
      Divider()
    }.contentShape(Rectangle())
      .onTapGesture {
        showMessageInfo = true
      }
      .sheet(isPresented: $showMessageInfo) {
        OfficialMessageInfoView(message: message)
      }
  }
}

struct OfficialMessageInfoView: View {

  let message: OfficialMessage
  @State private var signatureString: String = "Signature not verified as official."

  var body: some View {
    VStack(alignment: .leading) {

      OfficialMessageRow(message: message)

      Spacer()
      let certificatesString = message.certificate
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

      Spacer()
    }
    .onAppear(perform: verifySignature)
    .padding()
  }

  func verifySignature() {
    let certificatesString = message.certificate
    let certificates = getCertificatesFromCertifcateString(certificatestring: certificatesString)

    do {
      var serializer = DER.Serializer()
      try serializer.serialize(certificates[0])
      let serializerData = Data(serializer.serializedBytes)
      let secCertificate = SecCertificateCreateWithData(nil, serializerData as CFData)
      guard let pubKey = SecCertificateCopyKey(secCertificate!) else { return }
      if let signatureData = Data(base64Encoded: message.signature) {
        let messageData = message.content.data(using: .utf8)

        var error: Unmanaged<CFError>?
        let signatureVerified = SecKeyVerifySignature(
          pubKey,
          .rsaSignatureDigestPKCS1v15SHA512,
          messageData! as CFData,
          signatureData as CFData,
          &error)

        let issuerCommonName = getCommonName(subject: certificates[0].issuer)
        if signatureVerified && issuerCommonName.contains("Official") {
          signatureString = "Signature successfully verified."
        }
      }
    } catch let error {
      print(error)
    }
  }
}
