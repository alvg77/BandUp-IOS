//
//  ImageTextField.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct RoundBorderTextFieldStyle: TextFieldStyle {
    private let verticalPadding: CGFloat = 12
    private let cornerRadius: CGFloat = 15
    
    @FocusState var focus: Bool
    let sfSymbol: String?

    init() { sfSymbol = nil }
    
    init(sfSymbol: String?) {
        self.sfSymbol = sfSymbol
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        HStack {
            if let sfSymbol = sfSymbol {
                Image(systemName: sfSymbol)
                    .foregroundStyle(.purple)
                    .bold(focus)
            }
            configuration.focused($focus)
        }
        .padding(.horizontal)
        .padding(.vertical, verticalPadding)
        .background(Color(.systemGray6))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: focus ? 4 : 2).foregroundStyle(.purple))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
