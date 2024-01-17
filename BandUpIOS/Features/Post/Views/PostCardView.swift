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
    
    var likePost: ((Int) -> Void)?
    var unlikePost: ((Int) -> Void)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack (alignment: .center, spacing: 4) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    VStack (alignment: .leading) {
                        Text(post.creator.username).bold()
                        Text(post.createdAt.formatted())
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    FlairView(name: post.flair.name)
                        .padding(.leading)
                }
                
                Text(post.title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                HStack(spacing: 24) {
                    HStack(spacing: 3) {
                        Button {
                            if !post.liked {
                                likePost?(post.id)
                            } else {
                                unlikePost?(post.id)
                            }
                        } label: {
                            Image(systemName: post.liked ? "heart.fill" : "heart")
                                .foregroundStyle(post.liked ? .red : .primary)
                                .animation(.easeInOut, value: post.liked)
                        }
                        Text(post.likeCount.formattedString())
                    }
                    HStack {
                        Image(systemName: "bubble")
                        Text(post.commentCount.formattedString())
                    }
                }
                .font(.headline)
            }
            Spacer()
        }
        .padding(15)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
    }
}
