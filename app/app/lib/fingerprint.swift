//
//  fingerprint.swift
//  app
//
//  Created by Oliver Kamer on 27.08.23.
//

import CommonCrypto
import Foundation
import Security

private func SHA512(data: Data) -> Data? {
  var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
  data.withUnsafeBytes {
    _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
  }
  return Data(hash)
}

func fingerprint(publicKeyData: Data?) -> String? {

  if let cfData = publicKeyData {
    let hash = SHA512(data: cfData)
    let fullFingerprint = hash?.map { String(format: "%02hhX", $0) }.joined()

    let truncatedFingerprint = String(fullFingerprint?.prefix(24) ?? "")
    return truncatedFingerprint.chunked(by: 4).joined(separator: " ")
  }
  return nil
}
