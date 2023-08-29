//
//  postcodeFormatter.swift
//  app
//
//  Created by Oliver Kamer on 29.08.23.
//

import Foundation

func postcodeFormatter(_ number: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.groupingSeparator = ""
  return formatter.string(from: NSNumber(value: number)) ?? ""
}
