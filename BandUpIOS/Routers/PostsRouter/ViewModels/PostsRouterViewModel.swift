//
//  PostsRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.12.23.
//

import Foundation
import FlowStacks

enum PostScreen {
    case all(PostsViewModel)
    case selectPost
    case createPost(CreatePostViewModel)
    case updatePost
}

class PostsRouterViewModel: ObservableObject {
    @Published var routes: Routes<PostScreen> = []
    
    init() {
        routes.push(.all(.init(createPost: toCreatePost, selectPost: selectPost)))
    }
    
    func selectPost() {
        
    }
    
    func toCreatePost() {
        let viewModel = CreatePostViewModel(back: back)
        routes.presentCover(.createPost(viewModel), embedInNavigationView: true)
    }
    
    func toUpdatePost() {
        
    }
    
    func back() {
        routes.dismiss()
    }
}
