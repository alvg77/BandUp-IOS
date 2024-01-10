//
//  ContentView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AppRouter()
            .onAppear {
                try? JWTService.shared.removeToken()
            }
    }
}

#Preview {
    ContentView()
}
