//
//  RegisterRequest.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation

struct RegisterRequest: Encodable {
    var username: String
    var email: String
    var password: String
    var artistTypeId: Int
    var genreIds: [Int]
    var bio: String
    var location = Location()
    var contacts: Contacts
}
