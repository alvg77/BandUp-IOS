//
//  CreateUpdateAdvert.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

struct CreateUpdateAdvert: Encodable {
    var title: String
    var description: String
    var genreIds: [Int]
    var searchedArtistTypeIds: [Int]
}
