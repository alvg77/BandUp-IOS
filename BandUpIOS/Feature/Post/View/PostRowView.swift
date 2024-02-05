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
    let likeCount: Int
    let commentCount: Int
    let creator: UserDetails
    let createdAt: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                top
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                likeAndCommentCount
                Divider()
                creationDate
            }
            Spacer()
        }
        .padding(.all, 15)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 2, x: 0, y: 1)
    }
}

private extension PostRowView {
    @ViewBuilder var top: some View {
        HStack (alignment: .center, spacing: 4) {
            UserProfilePicture(width: 28, heigth: 28, cornerRadius: 10)
            Text(creator.username).bold()
            
            Spacer()
            
            FlairView(name: flair.name)
                .padding(.leading)
        }
    }
    
    @ViewBuilder var likeAndCommentCount: some View {
        HStack (spacing: 8) {
            Text("\(likeCount.formattedString()) likes")
            Text("·")
            Text("\(commentCount.formattedString()) comments")
        }
        .font(.footnote)
        .foregroundStyle(.gray)
    }
    
    @ViewBuilder var creationDate: some View {
        HStack {
            Image(systemName: "calendar")
            Text(createdAt.formatted())
        }
        .font(.footnote)
        .foregroundStyle(.gray)
    }
}

#Preview {
    PostRowView(title: "Post Title Number 1 Post Title Number One", flair: PostFlair(id: 1, name: "Question"), likeCount: 50, commentCount: 12, creator: UserDetails(id: 0, username: "User 1", email: "user@user.com"), createdAt: Date.now)
}
