//
//  PostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import SwiftUI
import Combine

class PostViewModel: ObservableObject, Identifiable, Equatable {
    let id: Int
    @Published var post: Post
    @Published var error: APIError?
    
    private var model: PostModel
    private var cancellables = Set<AnyCancellable>()
    
    var navigateToUpdatePost: ((Post, @escaping (Post) -> Void) -> Void)?
    var onDelete: (() -> Void)?
    var toAuth: (() -> Void)?
    
    init(post: Post, model: PostModel) {
        self.id = post.id
        self.post = post
        self.model = model
    }
    
    func toggleLiked() {
        if !model.posts.map({ $0.id }).contains(post.id) { self.post = model.posts[0] }
        self.model.toggleLikePost(id: post.id, onSuccess: onSuccess, handleError: handleError)
    }
    
    func refreshPost() {
        self.model.fetchPost(id: post.id, onSuccess: onSuccess, handleError: handleError)
    }
    
    func update() {
        navigateToUpdatePost?(post) { [weak self] in self?.post = $0 }
    }
    
    func delete() {
        model.deletePost(id: post.id, onSuccess: onDelete!, handleError: handleError)
    }
    
    static func == (lhs: PostViewModel, rhs: PostViewModel) -> Bool {
        lhs.id == rhs.id
    }

    private func onSuccess(post: Post) {
        self.post = post
        self.error = nil
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
