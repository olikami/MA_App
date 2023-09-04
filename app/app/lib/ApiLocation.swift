import Foundation

struct ApiLocation: Codable {
  let url: URL
  let postcode: Int
  let messages: [Message]
}
