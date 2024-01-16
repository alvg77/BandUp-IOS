//
//  PostCardView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI
import LinkPreview

struct PostCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var post: ShortenedPost
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack (spacing: 4) {
                    Image(systemName: "person.circle.fill").font(.title2)
                    Text(post.creator.username).bold()
                    
                    FlairView(name: post.flair.name).padding(.leading, 8)
                }
                
                Text(post.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(post.createdAt.formatted()).font(.caption)
                    .padding(.bottom, 8)
                
                Text(post.content)
                    .font(.footnote)
                    .lineLimit(4)
                    .mask {
                        LinearGradient(colors: [.clear, .black], startPoint: .bottom, endPoint: .top)
                    }
            }
            Spacer()
        }
        .padding(15)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
    }
}

#Preview {
    PostCardView(post: ShortenedPost(id: 1, title: "How can I get better at guitar?", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", flair: PostFlair(id: 1, name: "Question"), creator: UserDetails(id: 1, username: "User 1"), createdAt: Date.now))
}
