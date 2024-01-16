//
//  ShortenedPost.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 16.01.24.
//

import Foundation

struct ShortenedPost: Decodable, Identifiable {
    let id: Int
    var title: String
    var content: String
    var flair: PostFlair
    let creator: UserDetails
    let createdAt: Date
}
