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
    var flair: PostFlair
    let creator: UserDetails
    let commentCount: Int
    var likeCount: Int
    var liked: Bool
    let createdAt: Date
}
