//
//  PostsViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import Combine

class PostListViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var flairs: [PostFlair] = []
    @Published var queryString = ""
    @Published var selectedFlair: PostFlair?
    private var queryFlair: PostFlair?
    
    @Published var error: APIError?
    
    private var model: PostModel
    private var pageNo = 0
    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    var onDelete: (() -> Void)?
    var navigateToPostDetail: ((Post) -> Void)?
    var navigateToCreatePost: (() -> Void)?
    var toAuth: (() -> Void)?
    
    init(model: PostModel) {
        self.model = model
        
        self.model.$posts.sink { [weak self] in
            self?.posts = $0
        }.store(in: &cancellables)
        
        self.model.$flairs.sink { [weak self] in
            self?.flairs = $0
        }.store(in: &cancellables)
        
        queryStringChange.store(in: &cancellables)
        selectedFlairChange.store(in: &cancellables)
    }
    
    var queryStringChange: AnyCancellable {
        $queryString
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchPosts()
            }
    }
    
    var selectedFlairChange: AnyCancellable {
        $selectedFlair
            .sink { [weak self] flair in
                if flair != self?.queryFlair {
                    self?.queryFlair = flair
                    self?.fetchPosts()
                }
            }
    }
    

    func fetchPosts() {
        pageNo = 0
        model.fetchPosts(append: false, pageNo: pageNo, pageSize: pageSize, queryString: queryString, queryFlair: queryFlair, handleError: handleError)
    }
    
    func fetchNextPage(post: Post) {
        guard post.id == posts.last?.id else {
            return
        }
        pageNo += 1
        model.fetchPosts(append: true, pageNo: pageNo, pageSize: pageSize, queryString: queryString, queryFlair: queryFlair, handleError: handleError)
    }
    
    func postDetail(post: Post) {
        navigateToPostDetail?(post)
    }
    
    func createPost() {
        navigateToCreatePost?()
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
            return
        }
        self.error = error
    }
}
