//
//  AppRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import FlowStacks
import KeychainAccess

enum AppScreen {
    case auth(AuthRouterViewModel)
    case main(MainRouterViewModel)
}

class AppRouterViewModel: ObservableObject {
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    @Published var routes: Routes<AppScreen> = []
    
    init() {
        if let jwt = JWTService.shared.getToken() {
            routes.push(.main(.init()))
        } else {
            routes.push(.auth(.init(authenticate: authenticate)))
        }
    }
    
    func authenticate() {
        routes.popToRoot()
        routes.push(.main(.init()))
    }
}
