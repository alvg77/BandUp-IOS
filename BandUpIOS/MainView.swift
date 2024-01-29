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
            homeTab()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(TabScreen.home)
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

private extension MainView {
    @ViewBuilder private func homeTab() -> some View {
        PostsRouterView(toAuth: toAuth)
    }
}

#Preview {
    MainView(toAuth: {})
}
