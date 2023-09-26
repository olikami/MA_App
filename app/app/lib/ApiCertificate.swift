import Foundation

struct ApiCertificate: Codable {
  let url: URL
  let csr: URL
  let created: Date
  let user: URL
  let certificateString: String

  enum CodingKeys: String, CodingKey {
    case url
    case csr
    case created
    case user
    case certificateString = "certificate_string"
  }
}
