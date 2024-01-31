//
//  PostView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PostViewModel
    @FocusState var focus: Bool
    
    var body: some View {
        VStack {
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
                    
                    Divider()
                        .frame(maxWidth: .infinity).background(Color(.systemGray))
                        .padding(.bottom, 4)
                    
                }
                CommentListView(comments: viewModel.comments, updateComment: viewModel.updateComment, deleteComment: viewModel.deleteComment)
                
            }
            .scrollIndicators(.hidden)
            .padding(.all, 8)
            .ignoresSafeArea(edges: .bottom)
            .refreshable {
                viewModel.refreshPost()
            }
            
            HStack {
                TextField("Comment", text: $viewModel.newCommentContent)
                    .focused($focus)
                    .padding(.all, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if focus {
                    Button("Done") {
                        viewModel.createComment()
                    }
                    .disabled(viewModel.newCommentContent.isEmpty)
                }
            }
            .padding(.all, 8)
            .background(Color(.systemGray5))
        }
        .task {
            viewModel.fetchComments()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.post.creator.email == JWTService.shared.extractEmail() {
                    menu
                }
            }
        }
        .alert(
            "Oops! Something went wrong...",
            isPresented: $viewModel.error.isNotNil(),
            presenting: $viewModel.error,
            actions: { _ in },
            message: { error in
                Text(error.wrappedValue!.localizedDescription)
            }
        )
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
        UserProfilePicture(diameter: 40).padding(.trailing, 4)
        
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
