//
//  CreateUpdateComment.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

public struct CreateEditComment: Encodable {
    public var content: String
    public var postId: Int? = nil
    
    public init(content: String, postId: Int? = nil) {
        self.content = content
        self.postId = postId
    }
}
