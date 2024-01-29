//
//  CreatePostRequest.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import Foundation

struct CreateUpdatePost: Encodable {
    var title: String
    var url: String?
    var content: String
    var flairId: Int
}
