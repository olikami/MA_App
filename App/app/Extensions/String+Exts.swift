//
//  String+Exts.swift
//  PeerChat
//
//  Created by Oliver Kamer on 5/20/23.
//

import Foundation

extension String {
  var isSingleEmoji: Bool { count == 1 && containsEmoji }

  var containsEmoji: Bool { contains { $0.isEmoji } }

  var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

  var emojiString: String { emojis.map { String($0) }.reduce("", +) }

  var emojis: [Character] { filter { $0.isEmoji } }

  var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension String {
  func chunked(by chunkSize: Int) -> [String] {
    stride(from: 0, to: self.count, by: chunkSize).map {
      let start = self.index(self.startIndex, offsetBy: $0)
      let end = self.index(start, offsetBy: chunkSize, limitedBy: self.endIndex) ?? self.endIndex
      return String(self[start..<end])
    }
  }
}
