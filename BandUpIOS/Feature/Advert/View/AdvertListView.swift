//
//  AdvertListView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertListView: View {
    @ObservedObject var viewModel: AdvertListViewModel
    
    var body: some View {
        LoadingView(loading: viewModel.loading) {
            displayAdverts
        }
        .task {
            guard viewModel.adverts.isEmpty else { return }
            viewModel.fetchAdverts()
        }
        .refreshable {
            viewModel.fetchAdverts()
        }
        .navigationTitle("Adverts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    displayCreateButton
                    displayFilterButton
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

private extension AdvertListView {
    @ViewBuilder var displayCreateButton: some View {
        Button {
            viewModel.createAdvert()
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }
    
    @ViewBuilder var displayFilterButton: some View {
        Button {
            viewModel.filterAdverts() 
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
    }
    
    @ViewBuilder var displayAdverts:  some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.adverts) { advert in
                    AdvertRowView(title: advert.title, location: advert.location, genres: advert.genres, searchedArtistTypes: advert.searchedArtistTypes, creator: advert.creator, createdAt: advert.createdAt) {
                        viewModel.profileDetail(advert: advert)
                    }
                    .onTapGesture {
                        viewModel.advertDetail(advert: advert)
                    }
                    .onAppear {
                        viewModel.fetchNextPage(advert: advert)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdvertListView(viewModel: AdvertListViewModel(store: AdvertStore()))
    }.tint(.purple)
}
