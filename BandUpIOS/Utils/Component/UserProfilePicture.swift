//
//  UserProfilePicture.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI

struct UserProfilePicture: View {
    let diameter: CGFloat
    
    var body: some View {
        Image(systemName: "person.circle")
            .resizable()
            .frame(width: diameter, height: diameter)
    }
}

#Preview {
    UserProfilePicture(diameter: 50)
}
