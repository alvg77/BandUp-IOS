//
//  UserProfilePicture.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import SwiftUI
import AWSS3

struct UserProfilePicture: View {
    let imageURL: URL?
    let diameter: CGFloat
    
    var body: some View {
        if let imageURL = imageURL {
            AWSImage(imageURL: imageURL, shape: .circle, width: diameter, height: diameter)
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: diameter, height: diameter)
        }
    }
}

#Preview {
    UserProfilePicture(imageURL: nil, diameter: 50)
}
