//
//  PostRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.01.24.
//

import Foundation
import FlowStacks

enum PostScreen {
    case all(PostsViewModel)
    case post(PostViewModel)
    case modify(ModifyPostViewModel)
    case filter
}

class PostRouterViewModel: ObservableObject {
    @Published var routes: Routes<PostScreen> = []

    init() {
        self.routes = [
            .root(
                .all(.init(
                    createPost: modify,
                    selectPost: selectPost
                ))
            )
        ]
    }
    
    func all() {
        let viewModel = PostsViewModel(createPost: modify, selectPost: selectPost)
        routes.push(.all(viewModel))
    }
    
    func selectPost(post: Post) {
        let viewModel = PostViewModel(post: post)
        routes.push(.post(viewModel))
    }
    
    func modify(post: Post?) {
        let toPost = { (post: Post) in
            self.back()
//            self.selectPost(post: post)
        }
        
        let viewModel = post != nil ?
            ModifyPostViewModel(post: post!, toPost: toPost)
        :
            ModifyPostViewModel(toPost: toPost)
            
        routes.push(.modify(viewModel))
    }

    
    func filter() {
        
    }
    
    func back() {
        routes.pop()
    }
}
