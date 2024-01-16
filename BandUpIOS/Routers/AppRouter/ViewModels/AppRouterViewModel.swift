//
//  AppRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import FlowStacks

enum AppScreen {
    case auth(AuthRouterViewModel)
    case main(MainRouterViewModel)
}

class AppRouterViewModel: ObservableObject {
    @Published var routes: Routes<AppScreen> = []
    
    init() {
        if (JWTService.shared.getToken()) != nil {
            routes.push(.main(.init()))
        } else {
            routes.push(.auth(.init(authenticate: authenticate)))
        }
    }
    
    func authenticate() {
        routes.pop()
        routes.push(.main(.init()))
    }
}
