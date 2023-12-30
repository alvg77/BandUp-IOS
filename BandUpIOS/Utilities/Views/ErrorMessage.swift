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
        .padding(.vertical)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ErrorMessage(errorMessage: "Error")
}
