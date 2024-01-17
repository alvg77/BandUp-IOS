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
                LazyVStack (pinnedViews: [.sectionHeaders]) {
                    Section(header:
                        ScrollView(.horizontal) {
                            HStack {
                                Text("All")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .padding(.all, 8)
                                    .background(viewModel.selectedFlair == nil ? .purple : .gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        viewModel.selectedFlair = nil
                                        viewModel.filter.flairId = nil
                                        viewModel.getPosts()
                                    }
                                ForEach(viewModel.flairs) { flair in
                                    Text(flair.name)
                                        .bold()
                                        .foregroundStyle(.white)
                                        .padding(.all, 8)
                                        .background(viewModel.selectedFlair == flair ? .purple : .gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .onTapGesture {
                                            viewModel.selectedFlair = flair
                                            viewModel.filter.flairId = flair.id
                                            viewModel.getPosts()
                                        }
                                        
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .padding(.horizontal)
                    ) {
                        ForEach(viewModel.posts) { post in
                            PostCardView(post: post, likePost: viewModel.likePost, unlikePost: viewModel.unlikePost)
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
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    create
                }
            }
            .task {
//                if viewModel.posts.isEmpty {
                    viewModel.getPosts()
//                }
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
            Image(systemName: "square.and.pencil")
                .font(.system(size: 20))
                .bold()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PostsView(viewModel: PostsViewModel())
    }
}
