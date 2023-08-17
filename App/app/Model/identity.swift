//
//  idendity.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import CommonCrypto
import Foundation
import Security

class Identity: ObservableObject {
  private var privateKey: SecKey?

  func generatePrivateKey() {
    let keyAttributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits as String: 4096,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: false
      ],
    ]

    let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
    privateKey = SecKeyCreateRandomKey(keyAttributes as CFDictionary, error)

    if privateKey == nil {
      if let actualError = error?.pointee {
        print("Error generating key: \(actualError.takeRetainedValue())")
      } else {
        print("Unknown error generating key.")
      }
    }
  }

  func fingerprint() -> String? {
    guard let key = privateKey else {
      return nil
    }

    if let cfData = SecKeyCopyExternalRepresentation(key, nil) as Data? {
      let hash = SHA256(data: cfData)
      return hash?.map { String(format: "%02hhx", $0) }.joined()
    }

    return nil
  }

  private func SHA256(data: Data) -> Data? {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
  }

}
