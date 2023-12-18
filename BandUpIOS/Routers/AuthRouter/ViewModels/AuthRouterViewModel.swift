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
    
    init() {
        self.routes = [
            .root(
                .login(
                    .init(toRegister: toRegister)
                )
            )
        ]
    }
    
    func toLogin() {
        let vm = LoginViewModel(
            toRegister: toRegister
        )
        routes.push(.login(vm))
    }
    
    func toRegister() {
        let vm = RegisterViewModel()
        routes.push(.register(vm))
    }
}
