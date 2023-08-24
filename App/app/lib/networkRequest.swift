import Foundation

let baseURL = URL(string: "https://master-thesis.oli.fyi/")

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}

func httpRequest(
  endpoint: String, method: HttpMethod, data: Codable? = nil,
  completion: @escaping (Data?, URLResponse?, Error?) -> Void
) {
  guard let url = URL(string: endpoint, relativeTo: baseURL) else {
    print("Invalid URL")
    return
  }

  var request = URLRequest(url: url)
  request.httpMethod = method.rawValue

  // Add headers if needed, for instance for JSON content type
  if method == .post {
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // If data is provided, try converting to JSON and add to the request body
    if let data = data {
      do {
        let encoder = DRFJSONCoder()
        request.httpBody = try encoder.encode(data)  // Corrected this line
      } catch {
        print("Failed to serialize data to JSON: \(error)")
        return
      }
    }
  }

  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let httpResponse = response as? HTTPURLResponse {
      print("Status Code:", httpResponse.statusCode)
    }
    if let e = error {
      print("Error:", e)
    } else if let d = data {
      print("Data:", String(data: d, encoding: .utf8) ?? "")
    }
    completion(data, response, error)
  }

  task.resume()
}
