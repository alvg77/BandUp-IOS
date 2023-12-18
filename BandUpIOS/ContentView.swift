//
//  ContentView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // using navigation stack for navigation toolbar text
        NavigationStack {
            AuthRouter()
        }.tint(.purple)
    }
}

#Preview {
    ContentView()
}
