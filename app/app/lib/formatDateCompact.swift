//
//  formatDateCompact.swift
//  app
//
//  Created by Oliver Kamer on 04.09.23.
//

import Foundation

func formatDateCompact(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.dateFormat = "dd.MM. HH:mm"

  return formatter.string(from: date)
}
