//
//  PostCardView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct PostRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let flair: PostFlair
    let creator: UserDetails
    let createdAt: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack (alignment: .center, spacing: 4) {
                    UserProfilePicture(diameter: 40)
                        
                    VStack (alignment: .leading) {
                        Text(creator.username).bold()
                        Text(createdAt.formatted())
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    FlairView(name: flair.name)
                        .padding(.leading)
                }
                
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
            }
            Spacer()
        }
        .padding(15)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}

#Preview {
    PostRowView(title: "Post Title Number 1 Post Title Number One", flair: PostFlair(id: 1, name: "Question"), creator: UserDetails(id: 0, username: "User 1", email: "user@user.com"), createdAt: Date.now)
}
