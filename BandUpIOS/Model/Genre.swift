//
//  Genre.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation

struct Genre: Codable, Hashable, Identifiable, CustomStringConvertible {
    
    var id: Int
    var name: String
    
    var description: String { self.name }
}
