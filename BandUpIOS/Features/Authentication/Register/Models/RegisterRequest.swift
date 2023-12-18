//
//  RegisterRequest.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation



struct RegisterRequest: Codable {
    var username: String
    var email: String
    var password: String
    var artistType: String
    var genres: [String]
    var bio: String
    var location: String
}
