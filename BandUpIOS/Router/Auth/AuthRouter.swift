//
//  File.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 26.01.24.
//

import Foundation
import SwiftUI

enum AuthRoute: Equatable {
    case login(LoginViewModel)
    case register(RegisterViewModel)
    
    static func == (lhs: AuthRoute, rhs: AuthRoute) -> Bool {
        switch (lhs, rhs) {
        case (.login, .login), (.register, .register):
            return true
        default:
            return false
        }
    }
}

struct AuthPath: Hashable {
    var route: AuthRoute
    var hashValue = { UUID().uuid }
    
    init(route: AuthRoute) {
        self.route = route
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    static func == (lhs: AuthPath, rhs: AuthPath) -> Bool {
        lhs.route == rhs.route
    }
}

class AuthRouter: ObservableObject {
    var onComplete: () -> Void
    @Published var path = NavigationPath()
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    func initialView() -> AnyView {
        return AnyView(AuthView(navigateToLogin: navigateToLogin, navigateToRegister: navigateToRegister))
    }
    
    func navigateToLogin() {
        let viewModel = LoginViewModel()
        viewModel.navigateToRegister = navigateToRegister
        viewModel.onComplete = onComplete
        path.append(AuthPath(route: .login(viewModel)))
    }
    
    func navigateToRegister() {
        let viewModel = RegisterViewModel()
        viewModel.onComplete = onComplete
        path.append(AuthPath(route: .register(viewModel)))
    }
}
