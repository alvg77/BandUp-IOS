//
//  AdvertRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import SwiftUI

enum AdvertRoute: Equatable {
    case detail(AdvertViewModel)
    case createUpdate(AdvertCreateUpdateViewModel)
    case filter(AdvertFilterViewModel)
    
    static func == (lhs: AdvertRoute, rhs: AdvertRoute) -> Bool {
        switch (lhs, rhs) {
        case (.detail(let lhsViewModel), .detail(let rhsViewModel)):
            return lhsViewModel.advert.id == rhsViewModel.advert.id
        case (.createUpdate(let lhsViewModel), .createUpdate(let rhsViewModel)):
            return lhsViewModel.advertId == rhsViewModel.advertId
        case (.filter, .filter):
            return true
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
    
    var model = AdvertModel()
    var viewModel: AdvertListViewModel
    var toAuth: () -> Void
    
    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
        viewModel = AdvertListViewModel(model: model)
        viewModel.navigateToAdvertDetail = navigateToAdvertDetail
        viewModel.navigateToCreateAdvert = navigateToCreateAdvert
        viewModel.navigateToFilterAdverts = navigateToFilterAdverts
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
        let viewModel = AdvertViewModel(advert: advert, model: model)
        viewModel.onDelete = navigateBackToPrevious
        viewModel.navigateToUpdateAdvert = navigateToUpdateAdvert
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .detail(viewModel)))
    }
    
    func navigateToCreateAdvert() {
        let viewModel = AdvertCreateUpdateViewModel(model: model)
        viewModel.onCreate = navigateBackToPrevious
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .createUpdate(viewModel)))
    }
    
    func navigateToUpdateAdvert(advert: Advert, onUpdate: @escaping (Advert) -> Void) {
        let viewModel = AdvertCreateUpdateViewModel(advert: advert, model: model)
        viewModel.onUpdate = { [weak self] in
            onUpdate($0)
            self?.navigateBackToPrevious()
        }
        viewModel.toAuth = toAuth
        path.append(AdvertPath(route: .createUpdate(viewModel)))
    }
    
    func navigateToFilterAdverts() {
        let viewModel = AdvertFilterViewModel(model: model)
        viewModel.onComplete = navigateBackToPrevious
        path.append(AdvertPath(route: .filter(viewModel)))
    }
}
