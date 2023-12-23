//
//  AppRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import FlowStacks

enum AppScreen {
    case auth
    case main
}

class AppRouterViewModel: ObservableObject {
    @Published var routes: Routes<AppScreen> = []
    
    init() {
        
    }
    
    
}
