//
//  CommentModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation
import Combine

class CommentStore: ObservableObject {
    typealias OnComplete = () -> Void
    typealias OnSuccess = () -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var comments: [Comment] = []
    
    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    func fetchComments(appending: Bool, postId: Int, pageNo: Int, onComplete: OnComplete? = nil, handleError: @escaping HandleError) {
        CommentService.shared.getAll(postId: postId, pageNo: pageNo, pageSize: pageSize) 
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    onComplete?()
                case .failure(let error):
                    onComplete?()
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
        CommentService.shared.create(commentCreateRequest: new)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    handleError(error)
                }
            } receiveValue: { [weak self] in
                self?.comments.insert($0, at: 0)
            }
            .store(in: &cancellables)
    }
    
    func editComment(_ edit: CreateEditComment, id: Int, handleError: @escaping HandleError) {
        CommentService.shared.edit(commentId: id, commentEditRequest: edit) 
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
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
        CommentService.shared.delete(commentId: id) 
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    handleError(error)
                }
            } receiveValue: { [weak self] _ in
                if let index = self?.comments.firstIndex(where: { $0.id == id }) {
                    self?.comments.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
}
