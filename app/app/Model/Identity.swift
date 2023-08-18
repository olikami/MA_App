//
//  idendity.swift
//  app
//
//  Created by Oliver Kamer on 17.08.23.
//

import CertificateSigningRequest
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

  func getPublicKey() -> CFData? {
    guard let key = privateKey else {
      return nil
    }
    return SecKeyCopyExternalRepresentation(key, nil)
  }

  func generateCSR() -> String {
    let csr = CertificateSigningRequest()  //CSR with no fields, will use defaults of an RSA key with sha512
    let algorithm = KeyAlgorithm.ec(signatureType: .sha256)
    let csr = CertificateSigningRequest(keyAlgorithm: algorithm)  //CSR with a specific key
    let csr = CertificateSigningRequest(
      commonName: String?, organizationName: String?, organizationUnitName: String?,
      countryName: String?, stateOrProvinceName: String?, localityName: String?,
      emailAddress: String?, description: String?, keyAlgorithm: algorithm)  //Define any field you want in your CSR along with the key algorithm

    return csr.buildCSRAndReturnString(publicKeyBits, privateKey: privateKey, publicKey: publicKey)
  }

  func fingerprint() -> String? {

    if let cfData = self.getPublicKey() as Data? {
      let hash = SHA512(data: cfData)
      let fullFingerprint = hash?.map { String(format: "%02hhX", $0) }.joined()

      let truncatedFingerprint = String(fullFingerprint?.prefix(24) ?? "")
      return truncatedFingerprint.chunked(by: 4).joined(separator: " ")
    }

    return nil
  }

  private func SHA512(data: Data) -> Data? {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
  }

  func hasKey() -> Bool {
    if self.privateKey != nil { return true }
    return false
  }

}
