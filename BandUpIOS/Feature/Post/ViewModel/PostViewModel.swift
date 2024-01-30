//
//  PostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import SwiftUI
import Combine

class PostViewModel: ObservableObject {
    @Published var post: Post
    @Published var comments: [Comment] = []
    @Published var newCommentContent = ""
    
    @Published var error: APIError?
    
    private var commentPageNo = 0
    private let commentPageSize = 10
    private var postModel: PostModel
    private var commentModel: CommentModel
    private var cancellables = Set<AnyCancellable>()
    
    var navigateToUpdatePost: ((Post, @escaping (Post) -> Void) -> Void)?
    var onDelete: (() -> Void)?
    var toAuth: (() -> Void)?
    
    init(post: Post, model: PostModel) {
        self.post = post
        self.postModel = model
        self.commentModel = CommentModel()
        
        self.commentModel.$comments.sink { [weak self] in
            self?.comments = $0 
        }.store(in: &cancellables)
    }
    
    func toggleLiked() {
        if !postModel.posts.map({ $0.id }).contains(post.id) { self.post = postModel.posts[0] }
        self.postModel.toggleLikePost(id: post.id, onSuccess: onSuccessPost, handleError: handleError)
    }
    
    func refreshPost() {
        self.postModel.fetchPost(id: post.id, onSuccess: { [weak self] in
            self?.onSuccessPost(post: $0)
            self?.fetchComments()
        }, handleError: handleError)
    }
    
    func update() {
        navigateToUpdatePost?(post) { [weak self] in self?.post = $0 }
    }
    
    func delete() {
        postModel.deletePost(id: post.id, onSuccess: onDelete!, handleError: handleError)
    }
    
    func fetchComments() {
        commentPageNo = 0
        commentModel.fetchComments(appending: false, postId: post.id, pageNo: commentPageNo, pageSize: commentPageSize, handleError: handleError)
    }
    
    func fetchNextCommentPage(comment: Comment) {
        guard comment.id == comments.last?.id else {
            return
        }
        commentPageNo += 1
        commentModel.fetchComments(appending: true, postId: post.id, pageNo: commentPageNo, pageSize: commentPageSize, handleError: handleError)
    }
    
    func createComment() {
        commentModel.createComment(CreateUpdateComment(content: newCommentContent, postId: post.id), onSuccess: onSuccessComment, handleError: handleError)
    }
    
    func deleteComment(commentId: Int) {
        commentModel.deleteComment(id: commentId, handleError: handleError)
    }
    
    func updateComment(commentId: Int, content: String) {
        commentModel.updateComment(CreateUpdateComment(content: content), id: commentId, handleError: handleError)
    }

    private func onSuccessPost(post: Post) {
        self.post = post
    }
    
    private func onSuccessComment() {
        self.newCommentContent = ""
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        withAnimation {
            self.error = error
        }
    }
}
