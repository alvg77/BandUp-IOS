//
//  LoadingView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.02.24.
//

import SwiftUI

struct LoadingView<Content: View>: View {
    let loading: LoadingState
    var content: () -> Content
    
    var body: some View {
        if loading == .loading {
            ProgressView()
        } else {
            content()
        }
    }
}
