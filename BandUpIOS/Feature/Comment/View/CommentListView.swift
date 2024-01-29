//
//  CommentListView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct CommentListView: View {
    @StateObject var viewModel: CommentListViewModel
    
    init(postId: Int) {
        _viewModel = StateObject(wrappedValue: CommentListViewModel(postId: postId))
    }
    
    var body: some View {
        commentList
    }
}

private extension CommentListView {
    @ViewBuilder var commentList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.comments) { comment in
                    CommentRowView(
                        commentId: comment.id,
                        content: comment.content,
                        createdAt: comment.createdAd,
                        creator: comment.creator,
                        update: viewModel.updateComment,
                        delete: viewModel.deleteComment
                    )
                }
            }
        }
    }
}
