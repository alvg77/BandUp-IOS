//
//  ContentView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct ContentView: View {
    @State var auth: Bool

    init() {
        auth = JWTService.shared.getToken() == nil
    }
    
    var body: some View {
        if !auth {
            MainView {
                auth = true
            }
        } else {
            AuthRouterView {
                auth = false
            }
        }
    }
}

#Preview {
    ContentView()
}
