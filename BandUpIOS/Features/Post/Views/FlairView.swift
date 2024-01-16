//
//  FlairView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct FlairView: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .bold()
            .foregroundStyle(.white)
            .padding(.all, 4)
            .background(.purple)
            .clipShape(.capsule)
    }
}

#Preview {
    FlairView(name: "Flair preview")
}
