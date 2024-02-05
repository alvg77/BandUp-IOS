//
//  CardBackground.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 2.02.24.
//

import SwiftUI

struct CardBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(.all, 12)
            .background(colorScheme == .light ? .white : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 2, x: 0, y: 1)
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
