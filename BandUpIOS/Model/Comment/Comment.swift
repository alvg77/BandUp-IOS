//
//  Comment.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

public struct Comment: Decodable, Identifiable {
    public let id: Int
    public var content: String
    public var createdAt: Date
    public var creator: UserDetails
    
    enum CodingKeys: CodingKey {
        case id
        case content
        case createdAt
        case creator
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.creator = try container.decode(UserDetails.self, forKey: .creator)
    }
    
    public init(
        id: Int,
        content: String,
        createdAt: Date,
        creator: UserDetails
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.creator = creator
    }
}
