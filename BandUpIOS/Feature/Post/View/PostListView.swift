//
//  PostsView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct PostListView: View {
    @ObservedObject var viewModel: PostListViewModel
    
    var body: some View {
        ZStack {
            VStack {
                flairSelector
                    .padding(.horizontal)
                posts
                    .scrollIndicators(.hidden)
            }
            
            if viewModel.loading == .loading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .refreshable {
            viewModel.fetchPosts()
        }
        .task {
            guard viewModel.posts.isEmpty else { return }
            viewModel.fetchPosts()
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                createPostButton
            }
        }
        .searchable(text: $viewModel.queryString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search posts")
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

private extension PostListView {
    @ViewBuilder var flairSelector: some View {
        FlairSelectHScroll(flairs: viewModel.flairs, selected: $viewModel.selectedFlair)
    }
    
    @ViewBuilder private var error: some View {
        VStack {
            if let errorMessage = viewModel.error?.errorDescription {
                ErrorMessage(errorMessage: errorMessage)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer()
        }
    }
    
    @ViewBuilder private var posts: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.posts) { post in
                    PostRowView(title: post.title, flair: post.flair, likeCount: post.likeCount, commentCount: post.commentCount, creator: post.creator, createdAt: post.createdAt) {
                        viewModel.profileDetail(post: post)
                    }
                    .onTapGesture {
                        viewModel.postDetail(post: post)
                    }
                    .task {
                        viewModel.fetchNextPage(post: post)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    @ViewBuilder private var createPostButton: some View {
        Button {
            viewModel.createPost()
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }
}

#Preview {
    NavigationStack {
        PostListView(viewModel: PostListViewModel(
            store: PostStore(toAuth: {}),
            navigateToPostDetail: { _ in },
            navigateToCreatePost: {},
            navigateToProfileDetail: { _ in }
        ))
    }
}
