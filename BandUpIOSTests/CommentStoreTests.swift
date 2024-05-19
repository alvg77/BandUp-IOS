//
//  CommentStoreTests.swift
//  BandUpIOSTests
//
//  Created by Aleko Georgiev on 25.04.24.
//

import XCTest
@testable import BandUpIOS

class CommentStoreTests: XCTestCase {
    var userDetails = UserDetails(id: 1, username: "Username", email: "Email")
    var commentStore: CommentStore!
    var mockToAuth: (() -> Void)!
    var mockCommentService: MockCommentService!
    var toAuthCalled: Bool!
    
    override func setUp() {
        super.setUp()
        mockToAuth = { }
        mockCommentService = MockCommentService()
        commentStore = CommentStore(toAuth: mockToAuth, commentService: mockCommentService)
    }
    
    override func tearDown() {
        commentStore = nil
        mockCommentService = nil
        super.tearDown()
    }
    
    func testFetchComments() {
        let postId = 1
        let pageNo = 1
        let appending = true
        let testComment = Comment(id: 1, content: "Test Comment", createdAt: Date.now, creator: userDetails)
        mockCommentService.setCommentsForFetch([testComment])
        let expectation = XCTestExpectation(description: "Fetch Comments")
        
        commentStore.fetchComments(appending: appending, postId: postId, pageNo: pageNo, onSuccess: {
            expectation.fulfill()
        }) { error in
            XCTFail("Fetch Comments failed with error: \(String(describing: error))")
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(commentStore.comments.count, 1)
        XCTAssertEqual(commentStore.comments.first?.content, testComment.content)
    }
    
    
    func testCreateComment() {
        let newComment = CreateEditComment(content: "New Comment")
        let expectedComment = Comment(id: 1, content: "New Comment", createdAt: Date.now, creator: userDetails)
        
        mockCommentService.setCommentsForFetch([expectedComment])
        mockCommentService.setUserDetails(userDetails)
        
        let expectation = self.expectation(description: "Create Comment")
        
        commentStore.createComment(newComment, onSuccess: {
            expectation.fulfill()
        }) { error in
            XCTFail("Create Comment failed with error: \(String(describing: error))")
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(commentStore.comments.count, 1)
        XCTAssertEqual(commentStore.comments.first?.content, expectedComment.content)
    }
    
    
    func testEditComment() {
        let existingComment = Comment(id: 1, content: "Original Comment", createdAt: Date.now, creator: userDetails)
        commentStore.comments = [existingComment]
        let editedComment = CreateEditComment(content: "Edited Comment")
        let expectedComment = Comment(id: 1, content: "Edited Comment", createdAt: existingComment.createdAt, creator: existingComment.creator)
        mockCommentService.commentToEdit = expectedComment
        let expectation = XCTestExpectation(description: "Edit Comment")
        
        commentStore.editComment(editedComment, id: 1, onSuccess: {
            expectation.fulfill()
        }) { error in
            XCTFail("Edit Comment failed with error: \(String(describing: error))")
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(commentStore.comments.first?.content, expectedComment.content)
    }
    
    func testDeleteComment() {
        let id = 1
        mockCommentService.setCommentForDelete(Comment(id: id, content: "Comment to delete", createdAt: Date.now, creator: userDetails))
        
        commentStore.deleteComment(id: id, onSuccess: { [weak self] in
            XCTAssertEqual(self?.commentStore.comments.count, 0)
        }) { error in
            XCTFail("Delete Comment failed with error: \(String(describing: error))")
        }
    }
}
