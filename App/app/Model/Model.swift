//
//  File.swift
//  PeerChat
//
//  Created by Oliver Kamer on 06.07.23.
//

import CertificateSigningRequest
import Combine
import CommonCrypto
import Foundation
import Security
import SwiftUI
import X509

class Model: ObservableObject {

  @Published var person: Person?
  @Published var nearby: Nearby?

  // Setup attributes
  @Published var setupDone: Bool
  private var cancellables = Set<AnyCancellable>()

  // Identity attributes
  @Published var csr_string: String?
  @Published var applicationUser: ApiApplicationUser?
  @Published var certificate_string: String?
  let tagPrivate = "contact.oli.mt.app.private.ec"
  let tagPublic = "contact.oli.mt.app.public.ec"
  let algorithm = KeyAlgorithm.rsa(signatureType: .sha512)

  init() {
    self.setupDone = false
  }

  func createPerson(name: String) {
    self.person = Person(name, id: UUID())
  }

  func setNearby(person: Person) {
    self.nearby = Nearby(person: person)
  }

  // Start Identity

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

    DispatchQueue.main.async {
      self.csr_string = csrString
    }
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
          DispatchQueue.main.async {
            self.applicationUser = returnedUser
          }
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
      csrString: self.csr_string!,
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

  func getCertificates() -> [Certificate] {
    let pattern = "-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
      return []
    }
    guard let chain = self.certificate_string else { return [] }
    let nsString = chain as NSString
    let matches = regex.matches(
      in: chain, options: [], range: NSRange(location: 0, length: nsString.length))
    let pemStrings = matches.map { nsString.substring(with: $0.range) }
    do {
      let certificates = try pemStrings.map { try Certificate(pemEncoded: $0) }
      return certificates
    } catch let error {
      print(error)
    }
    return []
  }

  private func startPollingForCertificate(apiCSR: ApiCSR) {
    guard let url = apiCSR.url else {
      print("URL is missing!")
      return
    }

    var shouldContinuePolling = true

    DispatchQueue.global().async {
      while shouldContinuePolling {
        httpRequest(url: url, method: .get) { data, response, error in
          if let data = data {
            do {
              let decoder = DRFJSONCoder()
              let updatedApiCSR = try decoder.decode(ApiCSR.self, from: data)

              if let certificateUrl = updatedApiCSR.certificate {
                print("Certificate found:", certificateUrl)
                self.fetchCertificateDetails(from: certificateUrl) { certificateString in
                  DispatchQueue.main.async {
                    self.certificate_string = certificateString
                    self.setupDone = true
                  }
                  shouldContinuePolling = false
                }

              }
            } catch {
              print("Failed to decode the response data during polling: \(error)")
            }
          }
        }

        if shouldContinuePolling {
          sleep(10)  // Sleep for 10 seconds before the next iteration
        }
      }
    }
  }

  private func fetchCertificateDetails(from url: URL, completion: @escaping (String) -> Void) {
    httpRequest(url: url, method: .get) { data, response, error in
      if let data = data {
        do {
          let decoder = DRFJSONCoder()
          let apiCertificate = try decoder.decode(ApiCertificate.self, from: data)
          completion(apiCertificate.certificateString)
        } catch {
          print("Failed to decode ApiCertificate: \(error)")
        }
      }
    }
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

  // End Identity

  func generateKey() {
    self.generatePrivateKey()
  }

  func setupIsDone() {
    self.setupDone = true
  }
}

extension Model {
  var needsSetup: Binding<Bool> {
    Binding<Bool>(
      get: { self.setupDone == false },
      set: { newValue in
        if !newValue {
          self.person = nil
        }
      }
    )
  }
}
