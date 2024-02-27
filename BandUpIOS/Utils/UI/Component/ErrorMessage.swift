//
//  ErrorMessage.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import SwiftUI

struct ErrorMessage: View {
    let errorMessage: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(errorMessage)
                .font(.callout)
        }
        .foregroundStyle(.red)
        .cardBackground()
    }
}

#Preview {
    ErrorMessage(errorMessage: "Error")
}
