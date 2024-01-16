//
//  PostView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI
import LinkPreview

struct PostView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack (alignment: .leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill").font(.title2)
                        Text(viewModel.post.creator.username).bold()
                        FlairView(name: viewModel.post.flair.name).padding(.leading, 8)
                    }
                    
                    Text(viewModel.post.title)
                        .font(.title)
                        .foregroundStyle(.purple)
                        .fontWeight(.heavy)
                    
                    Text(viewModel.post.createdAt.formatted())
                        .bold()
                        .font(.caption)
                    
                    if let url = viewModel.post.url {
                        LinkPreview(url: URL(string: url))
                            .padding(.top)
                    }
                    
                    Text(viewModel.post.content)
                        .padding(.top)
                    
                    HStack {
                        likeDislikeView.padding(.trailing, 8)
                        commentsNumberView
                    }
                    .padding(.all, 2)
                    
                    Divider().frame(height: 0.5).background(Color(.systemGray))
                }
            }
            .padding(.all, 8)
            .ignoresSafeArea(edges: .bottom)
            .refreshable {
                viewModel.refreshPost()
            }
            
            VStack {
                if let errorMessage = viewModel.error?.errorDescription {
                    ErrorMessage(errorMessage: errorMessage)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
}

extension PostView {
    @ViewBuilder var likeDislikeView: some View {
        HStack (spacing: 4) {
            Button {
                if viewModel.post.liked {
                    viewModel.unlikePost()
                } else {
                    viewModel.likePost()
                }
            } label: {
                Image(systemName: viewModel.post.liked ? "heart.fill" : "heart")
                    .foregroundStyle(viewModel.post.liked ? .purple : .primary)
                    .font(.title2)
                    .animation(.easeInOut, value: viewModel.post.liked)
            }
            
            Text("\(viewModel.post.likeCount)").bold()
    
        }
        .padding(.all, 8)
        .background(Capsule().stroke(.primary, lineWidth: 0.5))
    }
    
    @ViewBuilder var commentsNumberView: some View {
        HStack (spacing: 4) {
            Image(systemName: "bubble").foregroundStyle(.primary).font(.title3)
            Text("\(viewModel.post.commentCount)").bold()
        }
        .padding(.all, 8)
        .background(Capsule().stroke(.primary, lineWidth: 0.5))
    }
}

#Preview {
    PostView(viewModel: PostViewModel(
        post: Post(id: 1,
                   title: "This is my first post on here",
                   url: "https://tuesfest.bg/projects/405",
                   content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
                   flair: PostFlair(id: 1, name: "Question"),
                   creator: UserDetails(id: 1, username: "user1", profilePicture: nil), commentCount: 991,
                   likeCount: 100,
                   liked: false,
                   createdAt: Date.now
                  )
    ))
}
