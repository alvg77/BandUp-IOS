//
//  PostsViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation

class PostsViewModel: ObservableObject {
    var createPost: ((Post?) -> Void)?
    var selectPost: ((Post) -> Void)?
    
    @Published var posts = [ShortenedPost]()
    @Published var filter = PostFilter()
    @Published var error: APIError?
    @Published var queryString = ""
    @Published var flairs = [PostFlair]()
    @Published var selectedFlair: PostFlair?
    
    let pageSize = 10
    var pageNo = 0
    
    init(createPost: ((Post?) -> Void)? = nil, selectPost: ((Post) -> Void)? = nil) {
        self.createPost = createPost
        self.selectPost = selectPost
    }
    
    func getPosts() {
        pageNo = 0 
        PostService.shared.getAll(pageNo: pageNo, pageSize: pageSize, filter: filter) { [weak self] comletion in
            DispatchQueue.main.async {
                switch comletion {
                case .success(let posts):
                    self?.error = nil
                    self?.posts = posts
                    self?.getFlairs()
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func getNextPage(postId: Int) {
        guard postId == posts[posts.endIndex - 1].id else {
            return
        }
        pageNo += 1
        PostService.shared.getAll(pageNo: pageNo, pageSize: pageSize, filter: filter) { [weak self] comletion in
            DispatchQueue.main.async {
                switch comletion {
                case .success(let posts):
                    self?.error = nil
                    self?.posts.append(contentsOf: posts)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func getFlairs() {
        PostFlairService.shared.getPostFlairs { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let flairs):
                    self?.flairs = flairs
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func selectPost(postId: Int) {
        PostService.shared.getById(postId: postId) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let post):
                    self?.error = nil
                    self?.selectPost?(post)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func likePost(postId: Int) {
        LikeService.shared.like(postId: postId) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    let index = self?.posts.firstIndex {
                        $0.id == postId
                    }
                    if let index = index {
                        self?.posts[index].liked.toggle()
                        self?.posts[index] .likeCount += 1
                    }
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
        
    func unlikePost(postId: Int) {
        LikeService.shared.unlike(postId: postId) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    let index = self?.posts.firstIndex {
                        $0.id == postId
                    }
                    if let index = index {
                        self?.posts[index].liked.toggle()
                        self?.posts[index] .likeCount -= 1
                    }
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
