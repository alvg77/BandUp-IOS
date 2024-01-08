//
//  AppRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI
import FlowStacks

struct AppRouter: View {
    @StateObject var viewModel = AppRouterViewModel()
    
    var body: some View {
        Router($viewModel.routes) { screen,_  in
            switch screen {
            case .auth(let viewModel):
                // navigation stack is used for titles and toolbars
                NavigationStack {
                    AuthRouter(viewModel: viewModel)
                }
                .tint(.primary)
            case .main(let viewModel):
                MainRouter(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    AppRouter()
}
