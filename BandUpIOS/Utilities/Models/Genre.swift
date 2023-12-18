//
//  Genre.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation

struct Genre: Decodable, Identifiable, CustomStringConvertible {
    var id: Int
    var name: String
    
    public var description: String { self.name }
}
