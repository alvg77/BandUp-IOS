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
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                    
                        VStack (alignment: .leading) {
                            Text(viewModel.post.creator.username).bold()
                            Text(viewModel.post.createdAt.formatted())
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        FlairView(name: viewModel.post.flair.name).padding(.leading, 8)
                    }
                    
                    Text(viewModel.post.title)
                        .font(.title)
                        .foregroundStyle(.purple)
                        .fontWeight(.heavy)
                    
                    if let url = viewModel.post.url {
                        LinkPreview(url: URL(string: url))
                    }
                    
                    Text(viewModel.post.content)
                        .padding(.bottom)
                    
                    HStack(spacing: 24) {
                        HStack(spacing: 3) {
                            Button {
                                if !viewModel.post.liked {
                                    viewModel.likePost()
                                } else {
                                    viewModel.unlikePost()
                                }
                            } label: {
                                Image(systemName: viewModel.post.liked ? "heart.fill" : "heart")
                                    .foregroundStyle(viewModel.post.liked ? .red : .primary)
                            }
                            Text(viewModel.post.likeCount.formattedString())
                        }
                        HStack {
                            Image(systemName: "bubble")
                            Text(viewModel.post.commentCount.formattedString())
                        }
                    }
                    .font(.system(size: 20))
                    .bold()
                    
                    Divider().frame(height: 0.5).background(Color(.systemGray))
                        .padding(.bottom)
                }
            }
            .scrollIndicators(.hidden)
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
