//
//  User.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import Foundation
import MapKit

struct User: Decodable, Identifiable {
    let id: Int
    var username: String
    var email: String
    var artistType: ArtistType
    var genres: [Genre]
    var profilePictureKey: String?
    var bio: String
    var location: Location
    var contacts: Contacts
    var createdAt: Date
}
