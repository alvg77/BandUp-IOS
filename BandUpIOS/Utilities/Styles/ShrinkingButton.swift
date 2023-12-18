//
//  GrowingButton.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import SwiftUI

struct ShrinkingButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.purple)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
