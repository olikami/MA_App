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
  @Published var csr: String?
  @Published var applicationUser: ApiApplicationUser?

  let tagPrivate = "contact.oli.mt.app.private.ec"
  let tagPublic = "contact.oli.mt.app.public.ec"

  let algorithm = KeyAlgorithm.rsa(signatureType: .sha512)

  func generatePrivateKey() {
    let queryDeletePublic: [String: Any] = [
      String(kSecClass): kSecClassKey,
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
    ]
    let queryDeletePrivate: [String: Any] = [
      String(kSecClass): kSecClassKey,
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrApplicationTag): tagPrivate.data(using: .utf8)!,
    ]

    SecItemDelete(queryDeletePublic as CFDictionary)
    SecItemDelete(queryDeletePrivate as CFDictionary)

    let publicKeyParameters: [String: Any] = [
      String(kSecAttrIsPermanent): true,
      String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
      String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
    ]

    let privateKeyParameters: [String: Any] = [
      String(kSecAttrIsPermanent): true,
      String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
      String(kSecAttrApplicationTag): tagPrivate.data(using: .utf8)!,
    ]

    let parameters: [String: Any] = [
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrKeySizeInBits): 2048,
      String(kSecReturnRef): true,
      String(kSecPublicKeyAttrs): publicKeyParameters,
      String(kSecPrivateKeyAttrs): privateKeyParameters,
    ]

    let error: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
    let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, error)

    if privateKey == nil {
      print("Error creating keys occured: keys weren't created")
    }
  }

  func getPrivateKey() -> SecKey? {
    //Get generated public key
    let query: [String: Any] = [
      String(kSecClass): kSecClassKey,
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrApplicationTag): tagPrivate.data(using: .utf8)!,
      String(kSecReturnRef): true,
    ]

    var privateKeyReturn: CFTypeRef?
    let result = SecItemCopyMatching(query as CFDictionary, &privateKeyReturn)
    if result != errSecSuccess {
      print("Error getting privateKey fron keychain occured: \(result)")
    }
    let privateKey = privateKeyReturn as! SecKey?
    return privateKey
  }

  func getPublicKey() -> SecKey? {
    //Get generated public key
    let query: [String: Any] = [
      String(kSecClass): kSecClassKey,
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
      String(kSecReturnRef): true,
    ]

    var publicKeyReturn: CFTypeRef?
    let result = SecItemCopyMatching(query as CFDictionary, &publicKeyReturn)
    if result != errSecSuccess {
      print("Error getting publicKey fron keychain occured: \(result)")
    }
    let publicKey = publicKeyReturn as! SecKey?
    return publicKey
  }

  func getPublicKeyData() -> Data? {

    //Ask keychain to provide the publicKey in bits
    let query: [String: Any] = [
      String(kSecClass): kSecClassKey,
      String(kSecAttrKeyType): algorithm.secKeyAttrType,
      String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
      String(kSecReturnData): true,
    ]

    var tempPublicKeyBits: CFTypeRef?
    var _ = SecItemCopyMatching(query as CFDictionary, &tempPublicKeyBits)

    guard let keyBits = tempPublicKeyBits as? Data else {
      return nil
    }
    return keyBits
  }

  func generateCSR(name: String) {
    guard let privateKey = self.getPrivateKey() else { return }
    guard let publicKey = self.getPublicKey() else { return }
    guard let publicKeyData = self.getPublicKeyData() else { return }
    let csr = CertificateSigningRequest(
      commonName: name, keyAlgorithm: algorithm)

    let csrString = csr.buildCSRAndReturnString(
      publicKeyData as Data,
      privateKey: privateKey,
      publicKey: publicKey
    )

    self.csr = csrString
  }

  func fingerprint() -> String? {

    if let cfData = self.getPublicKeyData() as Data? {
      let hash = SHA512(data: cfData)
      let fullFingerprint = hash?.map { String(format: "%02hhX", $0) }.joined()

      let truncatedFingerprint = String(fullFingerprint?.prefix(24) ?? "")
      return truncatedFingerprint.chunked(by: 4).joined(separator: " ")
    }

    return nil
  }

  func createApplicationUser(name: String) {
    let endpoint = "identity/application_user/"
    let (firstName, lastName) = splitName(name)
    let data = ApiApplicationUser(
      first_name: firstName, last_name: lastName ?? "", url: nil, uuid: nil)

    httpRequest(endpoint: endpoint, method: .post, data: data) { data, response, error in
      // Handle the response here
      if let data = data {
        do {
          let decoder = DRFJSONCoder()
          let returnedUser = try decoder.decode(ApiApplicationUser.self, from: data)
          print(returnedUser.url ?? "Somehow no User URL.")
          self.applicationUser = returnedUser
        } catch {
          print("Failed to decode the response data: \(error)")
        }
      }
    }
  }

  func requestCertificate() {
    let endpoint = "identity/csr/"
    let data = ApiCSR(
      uuid: nil, url: nil, created: nil, user: (self.applicationUser?.url?.absoluteString)!,
      csrString: self.csr!,
      status: nil, certificate: nil)

    httpRequest(endpoint: endpoint, method: .post, data: data) { data, response, error in
      if let data = data {
        do {
          let decoder = DRFJSONCoder()
          let apiCSR = try decoder.decode(ApiCSR.self, from: data)
          // Start the polling process
          if apiCSR.url != nil {
            self.startPollingForCertificate(apiCSR: apiCSR)
          }
        } catch {
          print("Failed to decode the response data: \(error)")
        }
      }
    }
  }

  private func startPollingForCertificate(apiCSR: ApiCSR) {
    guard let url = apiCSR.url else {
      print("URL is missing!")
      return
    }

    let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
      URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
          do {
            let decoder = DRFJSONCoder()
            let updatedApiCSR = try decoder.decode(ApiCSR.self, from: data)

            if let certificate = updatedApiCSR.certificate {
              print("Certificate found:", certificate)
              timer.invalidate()  // Stop the timer when the certificate is found
            }

          } catch {
            print("Failed to decode the response data during polling: \(error)")
          }
        }
      }.resume()  // Start the URLSession task
    }

    timer.fire()  // Start the timer immediately

  }

  private func SHA512(data: Data) -> Data? {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA512($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
  }

  func hasKey() -> Bool {
    if self.getPrivateKey() != nil { return true }
    return false
  }

}
