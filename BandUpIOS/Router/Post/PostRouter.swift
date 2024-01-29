//
//  PostsRoouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import Foundation
import SwiftUI

enum PostRoute: Equatable {
    case detail(PostViewModel)
    case createUpdate(CreateUpdatePostViewModel)
    
    static func == (lhs: PostRoute, rhs: PostRoute) -> Bool {
        switch (lhs, rhs) {
        case (.detail(let lhsViewModel), .detail(let rhsViewModel)):
            return lhsViewModel.post.id == rhsViewModel.post.id
        case (.createUpdate(let lhsViewModel), .createUpdate(let rhsViewModel)):
            return lhsViewModel.postId == rhsViewModel.postId
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
    
    var model = PostModel()
    var viewModel: PostListViewModel
    var toAuth: () -> Void

    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        viewModel = PostListViewModel(model: model)
        viewModel.navigateToPostDetail = navigateToPostDetail
        viewModel.navigateToCreatePost = navigateToCreatePost
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
        let viewModel = PostViewModel(post: post, model: model)
        viewModel.onDelete = navigateBackToPrevious
        viewModel.navigateToUpdatePost = navigateToUpdatePost
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .detail(viewModel)))
    }
    
    func navigateToCreatePost() {
        let viewModel = CreateUpdatePostViewModel(model: model)
        viewModel.onCreate = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .createUpdate(viewModel)))
    }
    
    func navigateToUpdatePost(post: Post, onUpdate: @escaping (Post) -> Void) {
        let viewModel = CreateUpdatePostViewModel(post: post, model: model)
        viewModel.onUpdate = { [weak self] in
            onUpdate($0)
            self?.navigateBackToPrevious()
        }
        viewModel.toAuth = toAuth
        path.append(PostPath(route: .createUpdate(viewModel)))
    }
}
