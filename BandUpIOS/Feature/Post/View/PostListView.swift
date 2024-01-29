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
        VStack {
            flairSelector
            ZStack {
                posts
                    .scrollIndicators(.hidden)
                    .refreshable {
                        viewModel.fetchPosts()
                    }
                    .task {
                        guard viewModel.posts.isEmpty else { return }
                        viewModel.fetchPosts()
                    }
                if let error = viewModel.error {
                    VStack {
                        Spacer()
                        ErrorMessage(errorMessage: error.localizedDescription)
                            .padding(.all)
                    }
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                createPostButton
            }
        }
        .searchable(text: $viewModel.queryString, placement: .navigationBarDrawer(displayMode: .always))
        
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
                    PostRowView(title: post.title, flair: post.flair, creator: post.creator, createdAt: post.createdAt)
                        .onTapGesture {
                            viewModel.postDetail(post: post)
                        }
                        .task {
                            viewModel.fetchNextPage(post: post)
                        }
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
    PostListView(viewModel: PostListViewModel(model: PostModel()))
}
