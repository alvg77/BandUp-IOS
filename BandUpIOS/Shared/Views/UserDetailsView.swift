//
//  UserDetailsView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 5.01.24.
//

import SwiftUI

struct UserDetailsView: View {
    var profilePic: String?
    var username: String
    
    let onTapGesture: (() -> Void)?
    
    var body: some View {
        HStack (spacing: 2) {
            if profilePic != nil {
                
            } else {
                Image(systemName: "person.circle")
                    .font(.custom("userDetails", fixedSize: 16))
            }
            Text(username)
                .font(.caption)
                .bold()
        }
        .onTapGesture {
            onTapGesture?()
        }
        .padding(.all, 4)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(.systemGray5))
        }
        .frame(maxHeight: 20)
    }
}

#Preview {
    UserDetailsView(profilePic: nil, username: "Username", onTapGesture: {})
}
