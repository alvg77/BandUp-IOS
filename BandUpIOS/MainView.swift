//
//  MainView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 18.01.24.
//

import SwiftUI

enum TabScreen {
    case home
    case adverts
    case profile
}

struct MainView: View {
    @State var tab: TabScreen = .home
    var toAuth: () -> Void
    
    var body: some View {
        appTabs()
    }
}

private extension MainView {
    @ViewBuilder private func appTabs() -> some View {
        TabView(selection: $tab) {
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabScreen.home)
            
            advertsTab
                .tabItem {
                    Label("Adverts", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(TabScreen.adverts)
            
            profileTab
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(TabScreen.profile)
        }
        .tint(.purple)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

private extension MainView {
    @ViewBuilder var homeTab: some View {
        PostsRouterView(toAuth: toAuth)
    }
    
    @ViewBuilder var advertsTab: some View {
        AdvertRouterView(toAuth: toAuth)
    }
    
    @ViewBuilder var profileTab: some View {
        ProfileRouterView(toAuth: toAuth)
    }
}

#Preview {
    MainView(toAuth: {})
}
