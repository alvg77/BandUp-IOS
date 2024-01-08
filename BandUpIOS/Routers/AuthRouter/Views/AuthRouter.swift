//
//  AuthRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 12.12.23.
//

import SwiftUI
import FlowStacks

struct AuthRouter: View {
    @ObservedObject var viewModel: AuthRouterViewModel
    
    var body: some View {
        Router($viewModel.routes) { screen,_  in
            switch screen {
            case .login(let viewModel):
                LoginView(viewModel: viewModel)
            case .register(let viewModel):
                RegisterView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    AuthRouter(viewModel: AuthRouterViewModel(authenticate: { }))
}
