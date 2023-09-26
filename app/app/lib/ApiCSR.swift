import Foundation

enum CertificateSigningRequestStatus: Int, Codable {
  case new = 0
  case approved = 1
  case denied = -1
}

struct ApiCSR: Codable {
  let uuid: String?
  let url: URL?
  let created: Date?
  let user: String?
  let csrString: String?
  let status: CertificateSigningRequestStatus?
  let certificate: URL?

  enum CodingKeys: String, CodingKey {
    case uuid
    case url
    case created
    case user
    case csrString = "csr_string"
    case status
    case certificate
  }
}
