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
import MultipeerConnectivity
import Security
import SwiftUI
import X509

class Model: NSObject, ObservableObject {

  @Published var person: Person?

  // Setup attributes
  @Published var setupDone: Bool = false
  private var cancellables = Set<AnyCancellable>()

  // Identity attributes
  @Published var csr_string: String?
  @Published var applicationUser: ApiApplicationUser?
  @Published var certificate_string: String?
  @Published var hasKey: Bool = false
  let tagPrivate = "contact.oli.mt.app.private.ec"
  let tagPublic = "contact.oli.mt.app.public.ec"
  let algorithm = KeyAlgorithm.rsa(signatureType: .sha512)

  // Messages attributes
  @Published var location: Int? {
    didSet {
      stopFetchingCommunityMessages()
      stopFetchingOfficialMessages()
      communityMessages = []
      officialMessages = []
      saveData()
      startFetchingCommunityMessages()
      startFetchingOfficialMessages()
      startLocalMessages()
    }
  }
  @Published var communityMessages: [Message] = []
  private var communityMessageTimer: Timer?

  // Official messsages attributes
  @Published var officialMessages: [OfficialMessage] = []
  private var officialMessagesTimer: Timer?

  // Local chat attributes
  private let serviceType = "COMUNILocal"
  private var localMessageSession: MCSession
  private var localMessageServiceAdvertiser: MCNearbyServiceAdvertiser
  private var localMessageServiceBrowser: MCNearbyServiceBrowser

  private let localMessageEncoder = PropertyListEncoder()
  private let localMessageDecoder = PropertyListDecoder()

  @Published var localPeers: [MCPeerID] = []
  @Published var localChats: [Person: Chat] = [:]

  override init() {
    let peerID = MCPeerID(displayName: "Startup")
    self.localMessageSession = MCSession(
      peer: peerID, securityIdentity: nil, encryptionPreference: .none)
    self.localMessageServiceAdvertiser = MCNearbyServiceAdvertiser(
      peer: peerID, discoveryInfo: nil, serviceType: serviceType)
    self.localMessageServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
    super.init()
    loadData()
  }

  func createPerson(name: String) {
    self.person = Person(name, id: UUID())
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
    hasKey = true

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
      return COMUNI.fingerprint(publicKeyData: cfData)
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
    guard let chain = self.certificate_string else { return [] }
    return getCertificatesFromCertifcateString(certificatestring: chain)
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
                    self.saveData()
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

  // End Identity

  // Start Messages

  func setLocation(location: Int) {
    self.location = location
  }

  func sendCommunityMessage(newMessage: String) {
    // Convert the message to Data
    guard let messageData = newMessage.data(using: .utf8) else { return }

    guard let privateKey = self.getPrivateKey() else { return }

    // Create a signature
    var error: Unmanaged<CFError>?
    guard
      let signature = SecKeyCreateSignature(
        privateKey,
        .rsaSignatureDigestPKCS1v15SHA512,
        messageData as CFData,
        &error
      )
    else {
      print("Error signing message: \(String(describing: error?.takeRetainedValue()))")
      return
    }

    // Convert the signature to Base64 string for easier storage/transmission
    let signatureString = (signature as Data).base64EncodedString()

    let newMessageObject = Message(
      text: newMessage, signature: signatureString, certificate: self.certificate_string,
      location: self.location)

    print(signatureString)

    // Send to endpoint
    let url = URL(string: "https://master-thesis.oli.fyi/messages/messages/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let encoder = DRFJSONCoder()

    do {
      let jsonData = try encoder.encode(newMessageObject)
      request.httpBody = jsonData

      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
          print("Error sending message: \(error)")
          return
        }

        if let httpResponse = response as? HTTPURLResponse,
          !(200...299).contains(httpResponse.statusCode)
        {
          print("Server responded with status code: \(httpResponse.statusCode)")
          if let data = data {
            let serverResponseString = String(data: data, encoding: .utf8)
            print("Server Response: \(String(describing: serverResponseString))")
          }
        } else {
          print("Message sent successfully!")
        }
      }
      task.resume()

    } catch {
      print("Error encoding message: \(error)")
    }

    self.communityMessages.append(newMessageObject)

  }

  func startFetchingCommunityMessages() {
    communityMessageTimer?.invalidate()  // Stop any previous timer
    communityMessageTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) {
      [weak self] _ in
      self?.fetchCommunityMessages()
    }
    fetchCommunityMessages()  // Fetch immediately
  }

  private func fetchCommunityMessages() {
    guard let location = self.location else { return }
    let urlString = "https://master-thesis.oli.fyi/messages/locations/\(location)/"
    guard let url = URL(string: urlString) else { return }

    let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      guard let data = data else { return }

      do {
        let decoder = DRFJSONCoder()
        let locationResponse = try decoder.decode(Location.self, from: data)
        self?.updateCommunityMessages(newMessages: locationResponse.messages)
      } catch {
        print("Failed to decode JSON:", error)
      }
    }
    task.resume()
  }

  private func updateCommunityMessages(newMessages: [Message]) {
    for message in newMessages {
      if !communityMessages.contains(message) {
        communityMessages.append(message)
      }
    }
    // Sort by date
    communityMessages.sort(by: { $0.sent < $1.sent })
  }

  func stopFetchingCommunityMessages() {
    communityMessageTimer?.invalidate()
    communityMessageTimer = nil
  }

  // End Messages

  // Start Official Messages

  func fetchOfficialMessages() {
    print("Fetch official messages")
    let url = URL(string: "https://master-thesis.oli.fyi/messages/official-messages/")!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        print("Error fetching data: \(error!)")
        return
      }

      guard let data = data else {
        print("No data fetched.")
        return
      }

      do {
        let messages = try DRFJSONCoder().decode([OfficialMessage].self, from: data)
        self.officialMessages = messages.filter { $0.locations.contains(self.location!) }
      } catch {
        print("Decoding error: \(error)")
      }
    }

    task.resume()
  }

  func startFetchingOfficialMessages() {
    print("Start start fetching")
    officialMessagesTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
      self.fetchOfficialMessages()
    }
    self.fetchOfficialMessages()
  }

  func stopFetchingOfficialMessages() {
    officialMessagesTimer?.invalidate()
    officialMessagesTimer = nil
  }

  // End Official Messages

  // Start Local Messages
  func startLocalMessages() {
    let peerID = MCPeerID(displayName: self.person!.name)
    self.localMessageSession = MCSession(
      peer: peerID, securityIdentity: nil, encryptionPreference: .none)
    self.localMessageServiceAdvertiser = MCNearbyServiceAdvertiser(
      peer: peerID, discoveryInfo: nil, serviceType: serviceType)
    self.localMessageServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)

    self.localMessageSession.delegate = self
    self.localMessageServiceAdvertiser.delegate = self
    self.localMessageServiceBrowser.delegate = self

    self.localMessageServiceAdvertiser.startAdvertisingPeer()
    self.localMessageServiceBrowser.startBrowsingForPeers()
  }

  func sendLocalMessage(_ messageText: String, chat: Chat) {
    print("send: \(messageText) to \(chat.peer.displayName)")

    DispatchQueue.main.async {
      guard let messageData = messageText.data(using: .utf8) else { return }
      guard let privateKey = self.getPrivateKey() else { return }

      // Create a signature
      var error: Unmanaged<CFError>?
      guard
        let signature = SecKeyCreateSignature(
          privateKey,
          .rsaSignatureDigestPKCS1v15SHA512,
          messageData as CFData,
          &error
        )
      else {
        print("Error signing message: \(String(describing: error?.takeRetainedValue()))")
        return
      }

      // Convert the signature to Base64 string for easier storage/transmission
      let signatureString = (signature as Data).base64EncodedString()
      let newMessage = ConnectMessage(
        messageType: .Message,
        message: Message(
          text: messageText, signature: signatureString, certificate: self.certificate_string,
          from: self.person))
      if !self.localMessageSession.connectedPeers.isEmpty {
        do {
          if let data = try? self.localMessageEncoder.encode(newMessage) {
            DispatchQueue.main.async {
              self.localChats[chat.person]?.messages.append(newMessage.message!)
            }
            try self.localMessageSession.send(data, toPeers: [chat.peer], with: .reliable)
          }
        } catch {
          print("Error for sending: \(String(describing: error))")
        }
      }
    }
  }

  func reciveInfo(info: ConnectMessage, from: MCPeerID) {
    print("Recived Info", info.messageType)
    if info.messageType == .Message {
      newMessage(message: info.message!, from: from)
    }
    if info.messageType == .PeerInfo {
      newPerson(person: info.peerInfo!, from: from)
    }
  }

  func newConnection(peer: MCPeerID) {
    print("New Connection ", peer.displayName)

    let newMessage = ConnectMessage(messageType: .PeerInfo, peerInfo: self.person)
    do {
      if let data = try? self.localMessageEncoder.encode(newMessage) {
        try self.localMessageSession.send(data, toPeers: [peer], with: .reliable)
      }
    } catch {
      print("Error for newConnection: \(String(describing: error))")
    }
  }

  func newPerson(person: Person, from: MCPeerID) {
    print("New Person ", person.name)
    self.localChats[person] = Chat(peer: from, person: person)

  }

  func newMessage(message: Message, from: MCPeerID) {
    print("New Message ", message.content)
    self.localChats[message.from!]!.messages.append(message)
  }

  // Ened Local Messages

  func generateKey() {
    self.generatePrivateKey()
  }

  func setupIsDone() {
    self.setupDone = true
  }

  // Make data persist

  func saveData() {
    let encoder = DRFJSONCoder()

    if let encodedUser = try? encoder.encode(applicationUser) {
      UserDefaults.standard.set(encodedUser, forKey: "ApplicationUser")
    }

    if let encodedPerson = try? encoder.encode(person) {
      UserDefaults.standard.set(encodedPerson, forKey: "Person")
    }

    UserDefaults.standard.set(setupDone, forKey: "SetupDone")
    UserDefaults.standard.set(certificate_string, forKey: "CertificateString")
    UserDefaults.standard.set(hasKey, forKey: "HasKey")
    UserDefaults.standard.set(location, forKey: "Location")
  }

  func loadData() {
    if let savedUser = UserDefaults.standard.object(forKey: "ApplicationUser") as? Data {
      let decoder = DRFJSONCoder()
      if let loadedUser = try? decoder.decode(ApiApplicationUser.self, from: savedUser) {
        self.applicationUser = loadedUser
      }
    }

    if let savedPerson = UserDefaults.standard.object(forKey: "Person") as? Data {
      let decoder = JSONDecoder()
      if let loadedPerson = try? decoder.decode(Person.self, from: savedPerson) {
        self.person = loadedPerson
      }
    }

    self.setupDone = UserDefaults.standard.bool(forKey: "SetupDone")
    self.certificate_string = UserDefaults.standard.string(forKey: "CertificateString")
    self.hasKey = UserDefaults.standard.bool(forKey: "HasKey")
    self.location = UserDefaults.standard.integer(forKey: "Location")
  }
}

extension Model: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
  {
    print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
  }

  func advertiser(
    _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
  ) {
    print("didReceiveInvitationFromPeer \(peerID)")
    DispatchQueue.main.async {
      invitationHandler(true, self.localMessageSession)
    }
  }
}

extension Model: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    print("peer \(peerID) didChangeState: \(state.rawValue)")
    DispatchQueue.main.async {
      if state == .connected {
        self.newConnection(peer: peerID)
      }
      self.localPeers = session.connectedPeers
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    print("didReceive bytes \(data.count) bytes")
    if let message = try? self.localMessageDecoder.decode(ConnectMessage.self, from: data) {
      DispatchQueue.main.async {
        self.reciveInfo(info: message, from: peerID)
      }
    }
  }

  public func session(
    _ session: MCSession, didReceive stream: InputStream, withName streamName: String,
    fromPeer peerID: MCPeerID
  ) {
    print("Receiving streams is not supported")
  }

  public func session(
    _ session: MCSession, didStartReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID, with progress: Progress
  ) {
    print("Receiving resources is not supported")
  }

  public func session(
    _ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?
  ) {
    print("Receiving resources is not supported")
  }
}

extension Model: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    print("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")

  }

  func browser(
    _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
    withDiscoveryInfo info: [String: String]?
  ) {
    print("ServiceBrowser found peer: \(peerID)")
    DispatchQueue.main.async {
      browser.invitePeer(peerID, to: self.localMessageSession, withContext: nil, timeout: 10)
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    print("ServiceBrowser lost peer: \(peerID)")
  }
}
