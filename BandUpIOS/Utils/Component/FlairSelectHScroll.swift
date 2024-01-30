//
//  FlairSelectScroll.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 19.01.24.
//

import SwiftUI

struct FlairSelectHScroll: View {
    let flairs: [PostFlair]
    @Binding var selected: PostFlair?
    
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text("All")
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.all, 8)
                    .background(selected == nil ? .purple : .gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        selected = nil
                    }
                ForEach(flairs) { flair in
                    Text(flair.name)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.all, 8)
                        .background(selected == flair ? .purple : .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            selected = flair
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
