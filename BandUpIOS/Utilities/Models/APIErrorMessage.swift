//
//  ErrorMessage.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 18.12.23.
//

import Foundation

struct APIErrorMessage: Decodable {
  var error: Bool
  var reason: String
}
