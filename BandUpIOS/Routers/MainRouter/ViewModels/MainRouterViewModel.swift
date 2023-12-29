//
//  MainRouterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 28.12.23.
//

import Foundation

enum MainScreen {
    case posts
    case advertisements
    case profile
}

class MainRouterViewModel: ObservableObject {
    @Published var selectedTab = MainScreen.posts
}
