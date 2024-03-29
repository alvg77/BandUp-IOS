//
//  PostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import SwiftUI
import Combine

class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var comments: [Comment] = []
    @Published var newCommentContent = ""
    @Published var postLoading: LoadingState = .notLoading
    @Published var commentsLoading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var commentPageNo = 0
    private var postStore: PostStore
    private var commentStore: CommentStore
    private var cancellables = Set<AnyCancellable>()
    
    private let onDelete: () -> Void
    private let navigateToEditPost: (Post) -> Void
    private let navigateToProfileDetail: (Int) -> Void
    
    var observePostUpdates: AnyCancellable {
        self.postStore.$posts.sink { [weak self] posts in
            if let post = posts.first(where: { $0.id == self?.post.id }) {
                self?.post = post
            }
        }
    }
    
    var observeCommentsUpdates: AnyCancellable {
        self.commentStore.$comments.sink { [weak self] in
            self?.comments = $0
        }
    }
    
    init(
        post: Post,
        postStore: PostStore,
        commentStore: CommentStore,
        onDelete: @escaping () -> Void,
        navigateToEditPost: @escaping (Post) -> Void,
        navigateToProfileDetail: @escaping (Int) -> Void
    ) {
        self.post = post
        self.postStore = postStore
        self.commentStore = commentStore
        self.onDelete = onDelete
        self.navigateToEditPost = navigateToEditPost
        self.navigateToProfileDetail = navigateToProfileDetail
        observePostUpdates.store(in: &cancellables)
        observeCommentsUpdates.store(in: &cancellables)
    }
    
    func togglePostLiked() {
        if !postStore.posts.map({ $0.id }).contains(post.id) { self.post = postStore.posts[0] }
        self.postStore.toggleLikePost(id: post.id, handleError: handleError)
    }
    
    func refreshPost() {
        postLoading = .loading
        self.postStore.fetchPost(id: post.id, onSuccess: { [weak self] in
            self?.postLoading = .notLoading
            self?.fetchComments()
        }, handleError: handleError)
    }
    
    func editPost() {
        navigateToEditPost(post)
    }
    
    func deletePost() {
        postStore.deletePost(id: post.id, onSuccess: { [weak self] in
                self?.postLoading = .notLoading
                self?.onDelete()
            }, handleError: handleError)
    }
    
    func profileDetail() {
        navigateToProfileDetail(post.creator.id)
    }
    
    func fetchComments() {
        commentsLoading = .loading
        commentPageNo = 0
        commentStore.fetchComments(appending: false, postId: post.id, pageNo: commentPageNo, onSuccess: { [weak self] in self?.commentsLoading = .notLoading }, handleError: handleError)
    }
    
    func fetchNextCommentPage(comment: Comment) {
        guard comment.id == comments.last?.id else {
            return
        }
        commentPageNo += 1
        commentStore.fetchComments(appending: true, postId: post.id, pageNo: commentPageNo, handleError: handleError)
    }
    
    func createComment() {
        commentStore.createComment(CreateEditComment(content: newCommentContent, postId: post.id), onSuccess: onSuccessComment, handleError: handleError)
    }
    
    func deleteComment(commentId: Int) {
        commentStore.deleteComment(id: commentId, onSuccess: { [weak self] in self?.post.commentCount -= 1 }, handleError: handleError)
    }
    
    func editComment(commentId: Int, content: String) {
        commentStore.editComment(CreateEditComment(content: content), id: commentId, handleError: handleError)
    }

    private func onSuccessPost(post: Post) {
        self.post = post
    }
    
    private func onSuccessComment() {
        self.newCommentContent = ""
        self.post.commentCount += 1
    }
    
    private func handleError(error: APIError?) {
        self.postLoading = .notLoading
        self.commentsLoading = .notLoading
        self.error = error
    }
}
