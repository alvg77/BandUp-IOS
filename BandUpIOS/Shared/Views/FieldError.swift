//
//  FieldError.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 23.12.23.
//

import SwiftUI

struct FieldError: View {
    var errorMessage: String
    
    var body: some View {
        Text(errorMessage)
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.push(from: .top))
            .padding(.leading)
    }
}

