//
//  RegisterRequest.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation

struct Location: Encodable {
    var country = ""
    var city = ""
    var postalCode = ""
}

struct RegisterRequest: Encodable {
    var username: String
    var email: String
    var password: String
    var artistType: ArtistType
    var genres: [Genre]
    var bio: String
    var location = Location()
}
