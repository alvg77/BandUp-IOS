//
//  CommentServiceMock.swift
//  BandUpIOSTests
//
//  Created by Aleko Georgiev on 25.04.24.
//

@testable import BandUpIOS
import Combine
import Foundation

class MockCommentService: CommentServiceProtocol {
    var userDetails: UserDetails? = nil
    var commentsToReturn: [Comment]? = nil
    var commentToEdit: Comment? = nil
    var commentToDelete: Comment? = nil
    private(set) var createCalled = false
    private(set) var getByIdCalled = false
    private(set) var getAllCalled = false
    private(set) var editCalled = false
    private(set) var deleteCalled = false

    func setCommentsForFetch(_ comments: [Comment]) {
        commentsToReturn = comments
    }

    func setCommentForEdit(_ comment: Comment) {
        commentToEdit = comment
    }

    func setCommentForDelete(_ comment: Comment) {
        commentToDelete = comment
    }
    
    func setUserDetails(_ userDetailsToSet: UserDetails) {
        userDetails = userDetailsToSet
    }

    func create(commentCreateRequest: CreateEditComment) -> AnyPublisher<Comment, APIError> {
        createCalled = true
        return commentsToReturn != nil
            ? Just(commentsToReturn!.first!).setFailureType(to: APIError.self).eraseToAnyPublisher()
            : Just(Comment(id: 1, content: commentCreateRequest.content, createdAt: Date.now, creator: userDetails!)).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }


    func getById(commentId: Int) -> AnyPublisher<Comment, APIError> {
        getByIdCalled = true
        return commentsToReturn != nil
            ? Just(commentsToReturn!.first(where: { $0.id == commentId })!).setFailureType(to: APIError.self).eraseToAnyPublisher()
            : Fail(error: APIError.unknownError).eraseToAnyPublisher()
    }

    func getAll(postId: Int, pageNo: Int, pageSize: Int) -> AnyPublisher<[Comment], APIError> {
        getAllCalled = true
        return commentsToReturn != nil
            ? Just(commentsToReturn!).setFailureType(to: APIError.self).eraseToAnyPublisher()
            : Fail(error: APIError.unknownError).eraseToAnyPublisher()
    }

    func edit(commentId: Int, commentEditRequest: CreateEditComment) -> AnyPublisher<Comment, APIError> {
        editCalled = true
        if let existingComment = commentToEdit, existingComment.id == commentId {
            let editedComment = Comment(id: commentId, content: commentEditRequest.content, createdAt: existingComment.createdAt, creator: existingComment.creator)
            return Just(editedComment).setFailureType(to: APIError.self).eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.unknownError).eraseToAnyPublisher()
        }
    }

    func delete(commentId: Int) -> AnyPublisher<Void, APIError> {
        deleteCalled = true
        return commentToDelete != nil
            ? Just(Void()).setFailureType(to: APIError.self).eraseToAnyPublisher()
            : Fail(error: APIError.unknownError).eraseToAnyPublisher()
    }
}
