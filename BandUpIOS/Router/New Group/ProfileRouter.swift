//
//  UserRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import Foundation
import SwiftUI

enum ProfileRoute: Equatable {
    case profileEdit(ProfileEditViewModel)

    static func == (lhs: ProfileRoute, rhs: ProfileRoute) -> Bool {
        switch (lhs, rhs) {
        case (.profileEdit(let lhsViewModel), .profileEdit(let rhsViewModel)):
            return lhsViewModel.userId == rhsViewModel.userId
        }
    }
}

struct ProfilePath: Hashable {
    var route: ProfileRoute
    var hashValue = { UUID().uuid }
    
    init(route: ProfileRoute) {
        self.route = route
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    static func == (lhs: ProfilePath, rhs: ProfilePath) -> Bool {
        lhs.route == rhs.route
    }
}

class ProfileRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    var viewModel: ProfileDetailViewModel
    var toAuth: () -> Void
    
    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        viewModel = ProfileDetailViewModel()
        viewModel.navigateToProfileEdit = navigateToProfileEdit
        viewModel.toAuth = toAuth
    }
    
    func initialView() -> AnyView {
        return AnyView(ProfileDetailView(viewModel: viewModel))
    }
    
    func navigateBackToRoot() {
        path = .init()
    }
    
    func navigateBackToPrevious() {
        path.removeLast()
    }
    
    func navigateToProfileEdit(user: User, onComplete: @escaping (User) -> Void) {
        let viewModel = ProfileEditViewModel(user: user)
        viewModel.toAuth = toAuth
        viewModel.onComplete = { [weak self] in
            onComplete($0)
            self?.navigateBackToPrevious()
        }
        path.append(ProfilePath(route: .profileEdit(viewModel)))
    }
}
