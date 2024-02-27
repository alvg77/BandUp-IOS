//
//  SwiftUIView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import SwiftUI

struct AuthRouterView: View {
    @StateObject var router: AuthRouter
    
    init(onComplete: @escaping () -> Void) {
        _router = StateObject(wrappedValue: AuthRouter(onComplete: onComplete))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            router.initialView()
                .navigationDestination(for: AuthPath.self, destination: destination)
        }.tint(.purple)
    }
}

private extension AuthRouterView {
    func destination(path: AuthPath) -> AnyView {
        switch path.route {
        case .login(let viewModel):
            return AnyView(LoginView(viewModel: viewModel))
        case .register(let viewModel):
            return AnyView(RegisterView(viewModel: viewModel))
        }
    }
}
