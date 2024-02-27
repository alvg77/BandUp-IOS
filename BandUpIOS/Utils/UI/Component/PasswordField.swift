//
//  PasswordView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import SwiftUI

struct PasswordField: View {
    @State var title: String
    @State var example = ""
    @Binding var text: String
    
    enum PassFocus {
        case hide
        case show
    }
    
    @FocusState var focus: PassFocus?
    
    let sfSymbol: String?
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title).foregroundStyle(.purple)
            HStack {
                if let sfSymbol = sfSymbol {
                    Image(systemName: sfSymbol)
                        .foregroundStyle(.purple)
                        .opacity(focus != nil ? 1 : 0.5)
                }
                ZStack {
                    TextField(example, text: $text)
                        .focused($focus, equals: .show)
                        .opacity(focus == .show ? 1 : 0)
                    SecureField(example, text: $text)
                        .focused($focus, equals: .hide)
                        .opacity(focus == .hide ? 1 : 0)
                }
            }
        }
    }
}
