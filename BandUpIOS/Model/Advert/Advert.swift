//
//  Advert.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

struct Advert: Decodable, Identifiable {
    let id: Int
    var title: String
    var description: String
    var location: Location
    var genres: [Genre]
    var searchedArtistTypes: [ArtistType]
    var createor: UserDetails
    var contacts: Contacts
    var createdAt: Date
}
