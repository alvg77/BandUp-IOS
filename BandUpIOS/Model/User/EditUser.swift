//
//  UpdateUser.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import Foundation

struct EditUser: Encodable {
    var username: String
    var profilePictureKey: String?
    var bio: String
    var genreIds: [Int]
    var artistTypeId: Int
    var contacts: Contacts
}
