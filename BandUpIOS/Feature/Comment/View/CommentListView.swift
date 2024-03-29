//
//  CommentListView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct CommentListView: View {
    var comments: [Comment]
    var editComment: (Int, String) -> Void
    var deleteComment: (Int) -> Void
    
    var body: some View {
        commentList
    }
}

private extension CommentListView {
    @ViewBuilder var commentList: some View {
        LazyVStack {
            ForEach(comments) { comment in
                CommentRowView(
                    commentId: comment.id,
                    content: comment.content,
                    createdAt: comment.createdAt,
                    creator: comment.creator,
                    edit: editComment,
                    delete: deleteComment
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}
