//
//  CommentModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

class CommentModel: ObservableObject {
    typealias OnSuccess = () -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var comments: [Comment] = []
    
    func fetchComments(appending: Bool, postId: Int, pageNo: Int, pageSize: Int, handleError: @escaping HandleError) {
        CommentService.shared.getAll(commentId: postId, pageNo: pageNo, pageSize: pageSize) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let comments):
                    if appending {
                        self?.comments.append(contentsOf: comments)
                    } else {
                        self?.comments = comments
                    }
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func createComment(_ new: CreateUpdateComment, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        CommentService.shared.create(commentCreateRequest: new) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let comment):
                    self?.comments.insert(comment, at: 0)
                    onSuccess()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func updateComment(_ update: CreateUpdateComment, id: Int,  handleError: @escaping HandleError) {
        CommentService.shared.update(commentId: id, commentUpdateRequest: update) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let comment):
                    if let index = self?.comments.firstIndex(where: { $0.id == id }) {
                        self?.comments[index] = comment
                    }
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func deleteComment(id: Int, handleError: @escaping HandleError) {
        CommentService.shared.delete(commentId: id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    if let index = self?.comments.firstIndex(where: { $0.id == id }) {
                        self?.comments.remove(at: index)
                    }
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
}
