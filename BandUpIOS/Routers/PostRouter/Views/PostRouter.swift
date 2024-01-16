//
//  PostRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.01.24.
//

import SwiftUI
import FlowStacks

struct PostRouter: View {
    @StateObject var viewModel = PostRouterViewModel()
    
    var body: some View {
        Router($viewModel.routes) { screen,_  in
            switch screen {
            case .all(let viewModel):
                PostsView(viewModel: viewModel)
            case .post(let viewModel):
                PostView(viewModel: viewModel)
            case .modify(let viewModel):
                ModifyPostView(viewModel: viewModel)
            case .filter:
                EmptyView()
            }
        }
    }
}

#Preview {
    AppRouter()
}
