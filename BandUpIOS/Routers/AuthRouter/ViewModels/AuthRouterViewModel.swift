//
//  AuthRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 12.12.23.
//

import Foundation
import Combine
import SwiftUI
import FlowStacks

class AuthRouterViewModel: ObservableObject {
    enum AuthScreen {
        case login(LoginViewModel)
        case register(RegisterViewModel)
    }
    
    @Published var routes: Routes<AuthScreen> = []
    
    let authenticate: (() -> Void)?
    
    init(authenticate: (() -> Void)?) {
        self.authenticate = authenticate
        self.routes = [
            .root(
                .login(
                    .init(authenticate: authenticate, toRegister: toRegister)
                )
            )
        ]
    }
    
    func toRegister() {
        let vm = RegisterViewModel(
            authenticate: authenticate
        )
        routes.push(.register(vm))
    }
}
