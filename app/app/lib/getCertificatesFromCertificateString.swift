//
//  getCertificatesFromCertificateString.swift
//  app
//
//  Created by Oliver Kamer on 04.09.23.
//

import Foundation
import X509

func getCertificatesFromCertifcateString(certificatestring: String) -> [Certificate] {

  let pattern = "-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----"
  guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
    return []
  }
  let nsString = certificatestring as NSString
  let matches = regex.matches(
    in: certificatestring, options: [], range: NSRange(location: 0, length: nsString.length))
  let pemStrings = matches.map { nsString.substring(with: $0.range) }
  do {
    let certificates = try pemStrings.map { try Certificate(pemEncoded: $0) }
    return certificates
  } catch let error {
    print(error)
  }
  return []
}
