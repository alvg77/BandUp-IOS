//
//  AdvertRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import SwiftUI

enum AdvertRoute: Equatable {
    case detail(AdvertDetailViewModel)
    case createEdit(AdvertCreateEditViewModel)
    case filter(AdvertFilterViewModel)
    case profileDetail(ProfileDetailViewModel)
    case profileEdit(ProfileEditViewModel)
    
    static func == (lhs: AdvertRoute, rhs: AdvertRoute) -> Bool {
        switch (lhs, rhs) {
        case (.detail(let lhsViewModel), .detail(let rhsViewModel)):
            return lhsViewModel.advert.id == rhsViewModel.advert.id
        case (.createEdit(let lhsViewModel), .createEdit(let rhsViewModel)):
            return lhsViewModel.advertId == rhsViewModel.advertId
        case (.filter, .filter):
            return true
        case (.profileDetail(let lhsViewModel), .profileDetail(let rhsViewModel)):
            return lhsViewModel.user?.id == rhsViewModel.user?.id
        case (.profileEdit(let lhsViewModel), .profileEdit(let rhsViewModel)):
            return lhsViewModel.userId == rhsViewModel.userId
        default:
            return false
        }
    }
}

struct AdvertPath: Hashable {
    var route: AdvertRoute
    var hashValue = { UUID().uuid }
    
    init(route: AdvertRoute) {
        self.route = route
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    static func == (lhs: AdvertPath, rhs: AdvertPath) -> Bool {
        lhs.route == rhs.route
    }
}

class AdvertRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    var store = AdvertStore()
    var viewModel: AdvertListViewModel
    var toAuth: () -> Void
    
    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        viewModel = AdvertListViewModel(store: store)
        viewModel.navigateToAdvertDetail = navigateToAdvertDetail
        viewModel.navigateToCreateAdvert = navigateToCreateAdvert
        viewModel.navigateToFilterAdverts = navigateToFilterAdverts
        viewModel.navigateToProfileDetail = navigateToProfileDetail
        viewModel.toAuth = toAuth
    }
    
    func initialView() -> AnyView {
        return AnyView(AdvertListView(viewModel: viewModel))
    }
    
    func navigateBackToRoot() {
        path = .init()
    }
    
    func navigateBackToPrevious() {
        path.removeLast()
    }
    
    func navigateToAdvertDetail(advert: Advert) {
        let viewModel = AdvertDetailViewModel(advert: advert, store: store)
        viewModel.onDelete = navigateBackToPrevious
        viewModel.navigateToEditAdvert = navigateToEditAdvert
        viewModel.navigateToProfileDetail = navigateToProfileDetail
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .detail(viewModel)))
    }
    
    func navigateToCreateAdvert() {
        let viewModel = AdvertCreateEditViewModel(store: store)
        viewModel.onSuccess = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .createEdit(viewModel)))
    }
    
    func navigateToEditAdvert(advert: Advert) {
        let viewModel = AdvertCreateEditViewModel(advert: advert, store: store)
        viewModel.onSuccess = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .createEdit(viewModel)))
    }
    
    func navigateToFilterAdverts() {
        let viewModel = AdvertFilterViewModel(store: store)
        viewModel.onSuccess = navigateBackToPrevious
        path.append(AdvertPath(route: .filter(viewModel)))
    }
    
    func navigateToProfileDetail(userId: Int) {
        let viewModel = ProfileDetailViewModel(userId: userId)
        viewModel.navigateToProfileEdit = navigateToProfileEdit
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .profileDetail(viewModel)))
    }
    
    func navigateToProfileEdit(user: User, onComplete: @escaping (User) -> Void) {
        let viewModel = ProfileEditViewModel(user: user)
        viewModel.toAuth = toAuth
        viewModel.onComplete = onComplete
        path.append(AdvertPath(route: .profileEdit(viewModel)))
    }
}
