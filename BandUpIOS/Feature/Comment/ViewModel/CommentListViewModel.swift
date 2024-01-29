//
//  CommentListViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation
import Combine

class CommentListViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var createContent = ""
    @Published var error: APIError?

    private var pageNo = 0
    private let pageSize = 10
    private let postId: Int
    private var model = CommentModel()
    private var cancellables = Set<AnyCancellable>()
    
    var toAuth: (() -> Void)?
    
    init(postId: Int) {
        self.postId = postId
        model.$comments.sink { [weak self] in
            self?.comments = $0
        }.store(in: &cancellables)
    }
    
    func fetchComments() {
        pageNo = 0
        model.fetchComments(appending: false, postId: postId, pageNo: pageNo, pageSize: pageSize, handleError: handleError)
    }
    
    func fetchNextPage(comment: Comment) {
        guard comment.id == comments.last?.id else {
            return
        }
        pageNo += 1
        model.fetchComments(appending: true, postId: postId, pageNo: pageNo, pageSize: pageSize, handleError: handleError)
    }
    
    func createComment() {
        model.createComment(CreateUpdateComment(content: createContent, postId: postId), onSuccess: onCreate, handleError: handleError)
    }
    
    func updateComment(commentId: Int, content: String) {
        model.updateComment(CreateUpdateComment(content: content), id: commentId, handleError: handleError)
    }
    
    func deleteComment(commentId: Int) {
        model.deleteComment(id: commentId, handleError: handleError)
    }
    
    private func onCreate() {
        createContent = ""
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
