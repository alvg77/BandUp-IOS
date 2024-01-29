//
//  Comment.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

struct Comment: Decodable, Identifiable {
    let id: Int
    var content: String
    var createdAd: Date
    var creator: UserDetails
    var createdAt: UserDetails
}
