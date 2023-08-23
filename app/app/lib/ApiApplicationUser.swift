//
//  ApplicationUser.swift
//  app
//
//  Created by Oliver Kamer on 23.08.23.
//

import Foundation

struct ApiApplicationUser: Codable {

  let first_name: String
  let last_name: String
  let url: URL?
  let uuid: String?
}
