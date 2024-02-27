//
//  PostsStore.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import Foundation
import Combine

//enum PostByid: Equatable {
//    case all
//    case owner(String)
//}

class PostStore: ObservableObject {
    typealias OnSuccess = () -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var posts: [Post] = []
    @Published var flairs: [PostFlair] = []
    
//    var cachedPosts: [PostByid: Post] = [:]
    
    let toAuth: () -> Void
    
    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
    }
    
    func fetchPosts(
        append: Bool,
        pageNo: Int,
        queryString: String?,
        queryFlair: PostFlair?,
        onSuccess: OnSuccess? = nil,
        handleError: @escaping HandleError
    ) {
        PostService.shared.getAll(
            pageNo: pageNo,
            pageSize: pageSize,
            queryString: queryString,
            flair: queryFlair
        )
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
            if append {
                self?.posts.append(contentsOf: $0)
            } else {
                self?.fetchFlairs(handleError: handleError)
                self?.posts = $0
            }
        }
        .store(in: &cancellables)
    }
    
    func createPost(
        _ new: CreateEditPost,
        onSuccess: @escaping OnSuccess,
        handleError: @escaping HandleError
    ) {
        PostService.shared.create(
            postCreateRequest: new
        ) 
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
            self?.posts.insert($0, at: 0)
        }
        .store(in: &cancellables)
    }
    
    func fetchPost(id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        PostService.shared.getById(postId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] post in
                if let index = self?.posts.firstIndex(where: { $0.id == post.id }) {
                    self?.posts[index] = post
                }
            }
            .store(in: &cancellables)
    }
    
    func editPost(_ edit: CreateEditPost, id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        PostService.shared.edit(
            postId: id,
            postEditRequest: edit
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                onSuccess()
            case .failure(let error):
                self?.checkAuth(error: error)
                handleError(error)
            }
        } receiveValue: { [weak self] post in
            if let index = self?.posts.firstIndex(where: { $0.id == post.id }) {
                self?.posts[index] = post
            }
        }
        .store(in: &cancellables)
    }
    
    func toggleLikePost(id: Int, handleError: @escaping HandleError) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else {
            return
        }
        if posts[index].liked {
            posts[index].liked = false
            posts[index].likeCount -= 1
            LikeService.shared.unlike(postId: id) 
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        handleError(error)
                        self?.posts[index].liked = true
                        self?.posts[index].likeCount += 1
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        } else {
            posts[index].liked = true
            posts[index].likeCount += 1
            LikeService.shared.like(postId: id)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        handleError(error)
                        self?.posts[index].liked = false
                        self?.posts[index].likeCount -= 1
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }
    
    func deletePost(id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        PostService.shared.delete(postId: id)
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
                if let index = self?.posts.firstIndex(where: { $0.id == id }) {
                    self?.posts.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchFlairs(onSuccess: OnSuccess? = nil, handleError: @escaping HandleError) {
        PostFlairService.shared.getPostFlairs()
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
                self?.flairs = $0
            }
            .store(in: &cancellables)
    }
    
    private func checkAuth(error: APIError) {
        if case .unauthorized = error {
            toAuth()
        }
    }
}
