//
//  MainRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 28.12.23.
//

import SwiftUI

struct MainRouter: View {
    @ObservedObject var viewModel: MainRouterViewModel
    
    var body: some View {
        TabView (selection: $viewModel.selectedTab) {

        }
        .tint(.primary)
    }
}

#Preview {
    MainRouter(viewModel: MainRouterViewModel())
}
