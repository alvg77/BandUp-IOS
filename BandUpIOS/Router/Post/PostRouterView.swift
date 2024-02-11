//
//  PostRouterView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import SwiftUI

struct PostsRouterView: View {
    @StateObject var router: PostRouter
    
    init(toAuth: @escaping () -> Void) {
        _router = StateObject(wrappedValue: PostRouter(toAuth: toAuth))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            router.initialView()
                .navigationDestination(for: PostPath.self, destination: destination)
        }.tint(.purple)
    }
}

private extension PostsRouterView {
    func destination(path: PostPath) -> AnyView {
        switch path.route {
        case .detail(let viewModel):
            return AnyView(PostDetailView(viewModel: viewModel))
        case .createEdit(let viewModel):
            return AnyView(PostCreateEditView(viewModel: viewModel))
        case .profileDetail(let viewModel):
            return AnyView(ProfileDetailView(viewModel: viewModel))
        case .profileEdit(let viewModel):
            return AnyView(ProfileEditView(viewModel: viewModel))
        }
    }
}
