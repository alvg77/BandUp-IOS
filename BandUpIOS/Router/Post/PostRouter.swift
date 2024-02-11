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
    
    var store = PostStore()
    var viewModel: PostListViewModel
    var toAuth: () -> Void

    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        viewModel = PostListViewModel(store: store)
        viewModel.navigateToPostDetail = navigateToPostDetail
        viewModel.navigateToCreatePost = navigateToCreatePost
        viewModel.navigateToProfileDetail = navigateToProfileDetail
        viewModel.toAuth = toAuth
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
        let viewModel = PostDetailViewModel(post: post, store: store)
        viewModel.onDelete = navigateBackToPrevious
        viewModel.navigateToEditPost = navigateToEditPost
        viewModel.navigateToProfileDetail = navigateToProfileDetail
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .detail(viewModel)))
    }
    
    func navigateToCreatePost() {
        let viewModel = PostCreateEditViewModel(store: store)
        viewModel.onSuccess = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .createEdit(viewModel)))
    }
    
    func navigateToEditPost(post: Post) {
        let viewModel = PostCreateEditViewModel(post: post, store: store)
        viewModel.onSuccess = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .createEdit(viewModel)))
    }
    
    func navigateToProfileDetail(userId: Int) {
        let viewModel = ProfileDetailViewModel(userId: userId)
        viewModel.navigateToProfileEdit = navigateToProfileEdit
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .profileDetail(viewModel)))
    }
    
    func navigateToProfileEdit(user: User, onComplete: @escaping (User) -> Void) {
        let viewModel = ProfileEditViewModel(user: user)
        viewModel.toAuth = toAuth
        viewModel.onComplete = onComplete
        path.append(PostPath(route: .profileEdit(viewModel)))
    }
}
