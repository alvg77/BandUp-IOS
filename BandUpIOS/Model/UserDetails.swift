//
//  UserDetails.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation

public struct UserDetails: Decodable {
    var id: Int
    var username: String
    var email: String
    var profilePictureKey: String?
    
    public enum CodingKeys: CodingKey {
        case id
        case username
        case email
        case profilePictureKey
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.profilePictureKey = try container.decodeIfPresent(String.self, forKey: .profilePictureKey)
    }
    
    public init(id: Int, username: String, email: String, profilePictureKey: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.profilePictureKey = profilePictureKey
    }
}
