//
//  SwiftUIView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 7.02.24.
//

import SwiftUI

struct ProfileRouterView: View {
    @StateObject var router: ProfileRouter
    
    init(toAuth: @escaping () -> Void) {
        _router = StateObject(wrappedValue: ProfileRouter(toAuth: toAuth))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            router.initialView()
                .navigationDestination(for: ProfilePath.self, destination: destination)
        }.tint(.purple)
    }
}

private extension ProfileRouterView {
    func destination(path: ProfilePath) -> AnyView {
        if case .profileEdit(let viewModel) = path.route {
            return AnyView(ProfileEditView(viewModel: viewModel))
        }
        return AnyView(EmptyView())
    }
}

#Preview {
    ProfileRouterView {}
}
