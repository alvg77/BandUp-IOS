//
//  CommentModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation
import Combine

class CommentStore: ObservableObject {
    typealias OnSuccess = () -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var comments: [Comment] = []
    
    let toAuth: () -> Void
    
    private let commentService: any CommentServiceProtocol

    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    init(toAuth: @escaping () -> Void, commentService: any CommentServiceProtocol = CommentService.shared) {
        self.toAuth = toAuth
        self.commentService = commentService
    }
    
    func fetchComments(appending: Bool, postId: Int, pageNo: Int, onSuccess: OnSuccess? = nil, handleError: @escaping HandleError) {
        commentService.getAll(postId: postId, pageNo: pageNo, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess?()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] in
                if appending {
                    self?.comments.append(contentsOf: $0)
                } else {
                    self?.comments = $0
                }
            }
            .store(in: &cancellables)
    }
    
    func createComment(_ new: CreateEditComment, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        commentService.create(commentCreateRequest: new)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] in
                self?.comments.insert($0, at: 0)
            }
            .store(in: &cancellables)
    }
    
    func editComment(_ edit: CreateEditComment, id: Int, onSuccess: OnSuccess? = nil, handleError: @escaping HandleError) {
        commentService.edit(commentId: id, commentEditRequest: edit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess?()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] comment in
                if let index = self?.comments.firstIndex(where: { $0.id == id }) {
                    self?.comments[index] = comment
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteComment(id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        commentService.delete(commentId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] _ in
                if let index = self?.comments.firstIndex(where: { $0.id == id }) {
                    self?.comments.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkAuth(error: APIError) {
        if case .unauthorized = error {
            toAuth()
        }
    }
}
