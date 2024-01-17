//
//  PostViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import SwiftUI

class PostViewModel: ObservableObject {
    @Published var post: Post
    @Published var error: APIError?
    
//    let updatePost: ((Post) -> Void)?
    
    init(post: Post) {
        self.post = post
        self.fetchComments()
    }
    
    func likePost() {
        LikeService.shared.like(postId: post.id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    self?.post.liked.toggle()
                    self?.post.likeCount += 1
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
        
    func unlikePost() {
        LikeService.shared.unlike(postId: post.id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    self?.post.liked.toggle()
                    self?.post.likeCount -= 1
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func refreshPost() {
        PostService.shared.getById(postId: post.id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    self?.post = post
                    self?.error = nil
                case .failure(let error):
                    withAnimation {
                        self?.error = error
                    }
                }
            }
        }
    }
    
    func delete() {
        PostService.shared.delete(postId: post.id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func update() {
        
    }
    
    func fetchComments() {
        
    }
}
