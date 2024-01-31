//
//  AdvertListView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertListView: View {
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

private extension AdvertListView {
    @ViewBuilder var adverts:  some View {
        ScrollView {
            LazyVStack {
                
            }
        }
    }
}

#Preview {
    AdvertListView()
}
