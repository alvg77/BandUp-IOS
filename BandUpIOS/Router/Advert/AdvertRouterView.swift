//
//  AdvertRouterView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertRouterView: View {
    @StateObject var router: AdvertRouter
    
    init(toAuth: @escaping () -> Void) {
        _router = StateObject(wrappedValue: AdvertRouter(toAuth: toAuth))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            router.initialView()
                .navigationDestination(for: AdvertPath.self, destination: destination)
        }.tint(.purple)
    }
}

private extension AdvertRouterView {
    func destination(path: AdvertPath) -> AnyView {
        switch path.route {
        case .detail(let viewModel):
            return AnyView(AdvertDetailView(viewModel: viewModel))
        case .createEdit(let viewModel):
            return AnyView(AdvertCreateEditView(viewModel: viewModel))
        case .filter(let viewModel):
            return AnyView(AdvertFilterView(viewModel: viewModel))
        case .profileDetail(let viewModel):
            return AnyView(ProfileDetailView(viewModel: viewModel))
        case .profileEdit(let viewModel):
            return AnyView(ProfileEditView(viewModel: viewModel))
        }
    }
}
