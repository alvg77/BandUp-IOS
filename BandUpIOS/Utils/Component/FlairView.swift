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
            .bold()
            .foregroundStyle(.white)
            .padding(.all, 4)
            .background(.purple)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    FlairView(name: "Flair preview")
}
