//
//  CreateUpdateComment.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

struct CreateUpdateComment: Encodable {
    var content: String
    var postId: Int? = nil
}
