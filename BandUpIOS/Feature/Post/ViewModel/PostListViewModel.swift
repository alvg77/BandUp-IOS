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
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var store: PostStore
    private var pageNo = 0
    private var cancellables = Set<AnyCancellable>()
    
    private let navigateToPostDetail: (Post) -> Void
    private let navigateToCreatePost: () -> Void
    private let navigateToProfileDetail: (Int) -> Void
    
    var observePostsChanges: AnyCancellable {
        self.store.$posts.sink { [weak self] in
            self?.posts = $0
        }
    }
    
    var observeFlairsChanges: AnyCancellable {
        self.store.$flairs.sink { [weak self] in
            self?.flairs = $0
        }
    }
    
    var queryStringChange: AnyCancellable {
        $queryString
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchPosts()
            }
    }
    
    // the value of selectedFlairChange is not set to the new one during the execution of .sink
    // that's why queryFlair is used
    var selectedFlairChange: AnyCancellable {
        $selectedFlair
            .sink { [weak self] flair in
                if flair != self?.queryFlair {
                    self?.queryFlair = flair
                    self?.fetchPosts()
                }
            }
    }
    
    init(
        store: PostStore,
        navigateToPostDetail: @escaping (Post) -> Void,
        navigateToCreatePost: @escaping () -> Void,
        navigateToProfileDetail: @escaping (Int) -> Void
    ) {
        self.store = store
        self.navigateToPostDetail = navigateToPostDetail
        self.navigateToCreatePost = navigateToCreatePost
        self.navigateToProfileDetail = navigateToProfileDetail
        observePostsChanges.store(in: &cancellables)
        observeFlairsChanges.store(in: &cancellables)
        queryStringChange.store(in: &cancellables)
        selectedFlairChange.store(in: &cancellables)
    }

    func fetchPosts() {
        loading = .loading
        pageNo = 0
        store.fetchPosts(
            append: false,
            pageNo: pageNo,
            queryString: queryString,
            queryFlair: queryFlair,
            onSuccess: { [weak self] in self?.loading = .notLoading },
            handleError: handleError
        )
    }
    
    func fetchNextPage(post: Post) {
        guard post.id == posts.last?.id else {
            return
        }
        pageNo += 1
        store.fetchPosts(append: true, pageNo: pageNo, queryString: queryString, queryFlair: queryFlair, handleError: handleError)
    }
    
    func postDetail(post: Post) {
        navigateToPostDetail(post)
    }
    
    func createPost() {
        navigateToCreatePost()
    }
    
    func profileDetail(post: Post) {
        navigateToProfileDetail(post.creator.id)
    }
    
    private func handleError(error: APIError?) {
        self.loading = .notLoading
        self.error = error
    }
}
