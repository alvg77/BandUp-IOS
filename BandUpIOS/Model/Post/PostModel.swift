//
//  PostsStore.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import Foundation
import Combine

class PostModel: ObservableObject {
    typealias OnSuccess = () -> Void
    typealias OnSuccessValue = (Post) -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var posts: [Post] = []
    @Published var flairs: [PostFlair] = []
    
    func fetchPosts(
        append: Bool,
        pageNo: Int,
        pageSize: Int,
        queryString: String?,
        queryFlair: PostFlair?,
        handleError: @escaping HandleError
    ) {
        PostService.shared.getAll(
            pageNo: pageNo,
            pageSize: pageSize,
            queryString: queryString,
            flair: queryFlair
        ) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let posts):
                    if append {
                        self?.posts.append(contentsOf: posts)
                    } else {
                        self?.fetchFlairs(handleError: handleError)
                        self?.posts = posts
                    }
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func addPost(_ new: CreateUpdatePost, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        PostService.shared.create(
            postCreateRequest: CreateUpdatePost(title: new.title, url: new.url, content: new.content, flairId: new.flairId)
        ) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    self?.posts.insert(post, at: 0)
                    onSuccess()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
                
            }
        }
    }
    
    func fetchPost(id: Int, onSuccess: @escaping OnSuccessValue, handleError: @escaping HandleError) {
        PostService.shared.getById(postId: id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    if let index = self?.posts.firstIndex(where: { $0.id == post.id }) {
                        self?.posts[index] = post
                    }
                    onSuccess(post)
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func updatePost(_ update: CreateUpdatePost, id: Int, onSuccess: @escaping OnSuccessValue, handleError: @escaping HandleError) {
        PostService.shared.update(
            postId: id,
            postUpdateRequest: update
        ) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    if let index = self?.posts.firstIndex(where: { $0.id == post.id }) {
                        self?.posts[index] = post
                    }
                    onSuccess(post)
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func toggleLikePost(id: Int, onSuccess: @escaping OnSuccessValue, handleError: @escaping HandleError) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else {
            return
        }
        if posts[index].liked {
            LikeService.shared.unlike(postId: id) { [weak self] completion in
                DispatchQueue.main.async {
                    switch completion {
                    case .success:
                        self?.posts[index].liked = false
                        self?.posts[index].likeCount -= 1
                        if let post = self?.posts[index] {
                            onSuccess(post)
                        }
                        handleError(nil)
                    case .failure(let error):
                        handleError(error)
                    }
                }
            }
        } else {
            LikeService.shared.like(postId: id) { [weak self] completion in
                DispatchQueue.main.async {
                    
                    switch completion {
                    case .success:
                        self?.posts[index].liked = true
                        self?.posts[index].likeCount += 1
                        if let post = self?.posts[index] {
                            onSuccess(post)
                        }
                        handleError(nil)
                    case .failure(let error):
                        handleError(error)
                    }
                }
            }
        }
    }
    
    func deletePost(id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        PostService.shared.delete(postId: id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    if let index = self?.posts.firstIndex(where: { $0.id == id }) {
                        self?.posts.remove(at: index)
                    }
                    onSuccess()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func fetchFlairs(handleError: @escaping HandleError) {
        PostFlairService.shared.getPostFlairs { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let flairs):
                    self?.flairs = flairs
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
}
