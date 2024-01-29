//
//  UserProfilePicture.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct UserProfilePicture: View {
    let width: CGFloat
    let heigth: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: heigth)
            .foregroundStyle(.white)
            .padding(.all, 4)
            .background(.purple)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    UserProfilePicture(width: 24, heigth: 24, cornerRadius: 10)
}
