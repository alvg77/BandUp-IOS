//
//  PostsView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import SwiftUI

struct PostsView: View {
    @ObservedObject var viewModel: PostsViewModel
    
    var body: some View {
        VStack {
            if let errorMessage = viewModel.error?.errorDescription {
                ErrorMessage(errorMessage: errorMessage)
                    .padding(.horizontal)
            }

            ScrollView {
                LazyVStack {
                    ForEach(viewModel.posts) { post in
                        PostCardView(post: post)
                            .task {
                                viewModel.getNextPage(postId: post.id)
                            }
                            .onTapGesture {
                                viewModel.selectPost(postId: post.id)
                            }
                        Divider()
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    create
                }
                ToolbarItem(placement: .topBarTrailing) {
                    filter
                }
            }
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.getPosts()
                }
            }
            .refreshable {
                viewModel.getPosts()
            }
        }
        .searchable(text: $viewModel.queryString, placement: .navigationBarDrawer(displayMode: .always)) {
            
        }
        .onSubmit(of: .search) {

        }
    }
}

extension PostsView {
    @ViewBuilder var create: some View {
        Button {
            viewModel.createPost?(nil)
        } label: {
            Image(systemName: "plus.square")
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder var filter: some View {
        Button {

        } label: {
            Image(systemName: "")
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PostsView(viewModel: PostsViewModel())
    }
}
