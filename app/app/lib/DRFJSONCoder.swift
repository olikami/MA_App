//
//  DRFJSONCoder.swift
//  app
//
//  Created by Oliver Kamer on 24.08.23.
//

import Foundation

class DRFJSONCoder {

  private static let isoDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  let decoder: JSONDecoder
  let encoder: JSONEncoder

  init() {
    self.decoder = JSONDecoder()
    self.encoder = JSONEncoder()

    // Date decoding strategy
    self.decoder.dateDecodingStrategy = .custom { decoder -> Date in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)
      guard let date = DRFJSONCoder.isoDateFormatter.date(from: dateString) else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "Invalid date string: \(dateString)")
      }
      return date
    }

    // Date encoding strategy
    self.encoder.dateEncodingStrategy = .custom { (date, encoder) throws in
      let dateString = DRFJSONCoder.isoDateFormatter.string(from: date)
      var container = encoder.singleValueContainer()
      try container.encode(dateString)
    }
  }

  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    return try decoder.decode(type, from: data)
  }

  func encode<T: Encodable>(_ value: T) throws -> Data {
    return try encoder.encode(value)
  }
}
