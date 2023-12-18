//
//  ArtistType.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation

struct ArtistType: Decodable, Identifiable, CustomStringConvertible, Hashable {
    var id: Int
    var name: String
    
    public var description: String { self.name }
}
