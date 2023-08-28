//
//  getCommonName.swift
//  app
//
//  Created by Oliver Kamer on 28.08.23.
//

import Foundation
import X509

func getCommonName(subject: DistinguishedName) -> String {
  let attribute = subject.first(where: { rdn in
    return rdn.first(where: { rdna in
      rdna.type == .RDNAttributeType.commonName
    }) != nil
  })
  let string = attribute?.description ?? "CN=Error"
  if let range = string.range(of: "CN=") {
    return String(string[range.upperBound...])
  }
  return "Error"
}
