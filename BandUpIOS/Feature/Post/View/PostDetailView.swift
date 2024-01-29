//
//  PostView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct PostDetailView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack (alignment: .leading) {
                    top
                    
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
                        likes
                        comments
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
                Spacer()
                if let errorMessage = viewModel.error?.errorDescription {
                    ErrorMessage(errorMessage: errorMessage)
                        .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.post.creator.email == JWTService.shared.extractEmail() {
                    menu
                }
            }
        }
    }
}

private extension PostDetailView {
    @ViewBuilder var top: some View {
        HStack(spacing: 4) {
            user
            Spacer()
            FlairView(name: viewModel.post.flair.name).padding(.leading, 8)
        }
    }
    
    @ViewBuilder var likes: some View {
        HStack(spacing: 3) {
            Button {
                viewModel.toggleLiked()
            } label: {
                Image(systemName: viewModel.post.liked ? "heart.fill" : "heart")
                    .foregroundStyle(viewModel.post.liked ? .red : .primary)
            }
            Text(viewModel.post.likeCount.formattedString())
        }
    }
    
    @ViewBuilder var comments: some View {
        HStack {
            Image(systemName: "bubble")
            Text(viewModel.post.commentCount.formattedString())
        }
    }
    
    @ViewBuilder var user: some View {
        UserProfilePicture(width: 28, heigth: 28, cornerRadius: 10)
        
        VStack (alignment: .leading) {
            Text(viewModel.post.creator.username).bold()
            Text(viewModel.post.createdAt.formatted())
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder var menu: some View {
        Menu {
            Button("Delete", role: .destructive, action: viewModel.delete)
            Button("Edit") { viewModel.update() }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}

#Preview {
    PostDetailView(viewModel: PostViewModel(
        post: Post(id: 1,
                   title: "This is my first post on here",
                   url: "https://tuesfest.bg/projects/405",
                   content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
                   flair: PostFlair(id: 1, name: "Question"),
                   creator: UserDetails(id: 1, username: "user1", email: "a@a.a", profilePicture: nil), 
                   commentCount: 991,
                   likeCount: 100,
                   liked: false,
                   createdAt: Date.now
                  ),
        model: PostModel()
    ))
}
