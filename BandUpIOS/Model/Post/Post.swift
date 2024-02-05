//
//  Post.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation

struct Post: Decodable, Identifiable {
    let id: Int
    var title: String
    var url: String?
    var content: String
    var flair: PostFlair
    let creator: UserDetails
    var commentCount: Int
    var likeCount: Int
    var liked: Bool
    let createdAt: Date
}
