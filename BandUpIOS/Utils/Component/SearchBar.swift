//
//  SearchBar.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 3.02.24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool

    var onSearchButtonClicked: () -> Void

    var body: some View {
        HStack {
            TextField("Search for cities", text: $text, onCommit: {
                onSearchButtonClicked()
            })
            .padding(.all, 7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if isEditing {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
            )
            .onTapGesture {
                isTextFieldFocused = true
            }
            .focused($isTextFieldFocused)

            Spacer()

            Button(action: {
                onSearchButtonClicked()
            }) {
                Text("Search")
                    .padding(.all, 7)
                    .foregroundStyle(.white)
                    .background(.purple)
                    .cornerRadius(10)
            }
        }
    }
}
