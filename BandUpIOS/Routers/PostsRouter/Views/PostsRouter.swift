//
//  PostsRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.12.23.
//

import SwiftUI
import FlowStacks

struct PostsRouter: View {
    @StateObject var viewModel = PostsRouterViewModel()
    
    var body: some View {
        Router($viewModel.routes) { screen,_ in
            switch screen {
            case .all(let viewModel):
                PostsView(viewModel: viewModel)
            case .selectPost:
                EmptyView()
            case .createPost(let viewModel):
                CreatePostView(viewModel: viewModel)
            case .updatePost:
                EmptyView()
            }
        }
    
    }
}

#Preview {
    NavigationStack {
        PostsRouter()
    }
}
