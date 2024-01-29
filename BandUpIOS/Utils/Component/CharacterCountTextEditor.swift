//
//  CharacterCountTextEditor.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import SwiftUI

struct CharacterCountTextEditor: View {
    let maxChars: Int
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>, maxChars: Int) {
        self.placeholder = placeholder
        self._text = text
        self.maxChars = maxChars
    }
    
    var body: some View {
        ZStack (alignment: .leading) {
            ZStack {
                TextEditor(text: $text)
                    .frame(minHeight: 200)
                    
                Spacer()
                VStack {
                    Text(placeholder)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.systemGray2))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(text.isEmpty ? 1 : 0)
                        .padding(.top, 8)
                        .padding(.leading, 4)

                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("\(text.count) / \(maxChars)")
                            .foregroundStyle(text.count < maxChars ? .gray : .red)
                            .padding(.trailing, 20)
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                }
                
            }

        }
    }
}
