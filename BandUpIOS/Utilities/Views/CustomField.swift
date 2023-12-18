//
//  CustomField.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import SwiftUI

struct CustomField: View {
    @State var title: String
    @State var example = ""
    @Binding var text: String
    @FocusState var focus: Bool
    
    let sfSymbol: String?
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title).foregroundStyle(.purple)
            HStack {
                if let sfSymbol = sfSymbol {
                    Image(systemName: sfSymbol)
                        .foregroundStyle(.purple)
                        .opacity(focus ? 1 : 0.5)
                }
                TextField(example, text: $text)
                    .focused($focus)
            }
            HorizontalLine(color: .purple, height: focus ? 2 : 1)
        }
    }
}
