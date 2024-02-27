//
//  PostsRoouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import Foundation
import SwiftUI

enum PostRoute: Equatable {
    case detail(PostDetailViewModel)
    case createEdit(PostCreateEditViewModel)
    case profileDetail(ProfileDetailViewModel)
    case profileEdit(ProfileEditViewModel)
    
    static func == (lhs: PostRoute, rhs: PostRoute) -> Bool {
        switch (lhs, rhs) {
        case (.detail(let lhsViewModel), .detail(let rhsViewModel)):
            return lhsViewModel.post.id == rhsViewModel.post.id
        case (.createEdit(let lhsViewModel), .createEdit(let rhsViewModel)):
            return lhsViewModel.postId == rhsViewModel.postId
        case (.profileDetail(let lhsViewModel), .profileDetail(let rhsViewModel)):
            return lhsViewModel.user?.id == rhsViewModel.user?.id
        case (.profileEdit(let lhsViewModel), .profileEdit(let rhsViewModel)):
            return lhsViewModel.userId == rhsViewModel.userId
        default:
            return false
        }
    }
}

struct PostPath: Hashable {
    var route: PostRoute
    var hashValue = { UUID().uuid }
    
    init(route: PostRoute) {
        self.route = route
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    static func == (lhs: PostPath, rhs: PostPath) -> Bool {
        lhs.route == rhs.route
    }
}

class PostRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    private var store: PostStore
    private let toAuth: () -> Void
    private lazy var viewModel: PostListViewModel = {
        PostListViewModel(
            store: store,
            navigateToPostDetail: navigateToPostDetail,
            navigateToCreatePost: navigateToCreatePost,
            navigateToProfileDetail: navigateToProfileDetail
        )
    }()

    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        self.store = PostStore(toAuth: toAuth)
    }
    
    func initialView() -> AnyView {
        return AnyView(PostListView(viewModel: viewModel))
    }
    
    func navigateBackToRoot() {
        path = .init()
    }
    
    func navigateBackToPrevious() {
        path.removeLast()
    }
    
    func navigateToPostDetail(post: Post) {
        let viewModel = PostDetailViewModel(
            post: post,
            postStore: store,
            commentStore: CommentStore(toAuth: toAuth),
            onDelete: navigateBackToPrevious,
            navigateToEditPost: navigateToEditPost,
            navigateToProfileDetail: navigateToProfileDetail
        )
        path.append(PostPath(route: .detail(viewModel)))
    }
    
    func navigateToCreatePost() {
        let viewModel = PostCreateEditViewModel(store: store, onSuccess: navigateBackToPrevious)
        path.append(PostPath(route: .createEdit(viewModel)))
    }
    
    func navigateToEditPost(post: Post) {
        let viewModel = PostCreateEditViewModel(post: post, store: store, onSuccess: navigateBackToPrevious)
        path.append(PostPath(route: .createEdit(viewModel)))
    }
    
    func navigateToProfileDetail(userId: Int) {
        let viewModel = ProfileDetailViewModel(
            userId: userId,
            navigateToProfileEdit: navigateToProfileEdit,
            toAuth: toAuth
        )
        path.append(PostPath(route: .profileDetail(viewModel)))
    }
    
    func navigateToProfileEdit(user: User, onSuccess: @escaping (User) -> Void) {
        let viewModel = ProfileEditViewModel(user: user, onSuccess: { [weak self] in
            onSuccess($0)
            self?.navigateBackToPrevious()
        }, toAuth: toAuth)
        path.append(PostPath(route: .profileEdit(viewModel)))
    }
}
