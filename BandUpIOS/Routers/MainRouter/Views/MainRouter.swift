//
//  MainRouter.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 28.12.23.
//

import SwiftUI
import KeychainAccess

struct MainRouter: View {
    @ObservedObject var viewModel: MainRouterViewModel
    
    var body: some View {
        TabView (selection: $viewModel.selectedTab) {
            NavigationStack {
//                PostsRouter()
            }
            .tabItem {
                Label("", systemImage: "house")
            }
            .tag(MainScreen.posts)
            
            NavigationStack {
//                AdvertisementsRouter()
            }
            .tabItem {
                Label("", systemImage: "doc.text.magnifyingglass")
            }
            .tag(MainScreen.advertisements)
            
            NavigationStack {
//                UsersRouter()
            }
            .tabItem {
                Label("", systemImage: "person")
            }
            .tag(MainScreen.profile)
        }
        .tint(.primary)
    }
}

#Preview {
    MainRouter(viewModel: MainRouterViewModel())
}
