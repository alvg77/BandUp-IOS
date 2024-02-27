//
//  AdvertDetailView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI
import MapKit

struct AdvertDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: AdvertDetailViewModel

    var body: some View {
        LoadingView(loading: viewModel.loading) {
            ScrollView {
                displayCreator
                displayAdvertDetails
                
                Divider()
                
                displayGenres
                displaySearchedArtistTypes
                
                Divider()
                
                displayCreatorContacts
                
                Divider()
                
                displayLocation
                
            }
        }
        .padding(.horizontal)
        .scrollIndicators(.hidden)
        .navigationTitle("Advert")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.refreshAdvert()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                displayMenu
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

private extension AdvertDetailView {
    @ViewBuilder var displayCreator: some View {
        HStack {
            Group {
                UserProfilePicture(imageKey: viewModel.advert.creator.profilePictureKey, diameter: 40)
                Text(viewModel.advert.creator.username).bold()
            }
            .onTapGesture {
                viewModel.profileDetail()
            }
            
            Spacer()
            
            Text(viewModel.advert.createdAt.formatted())
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder var displayAdvertDetails: some View {
        VStack(alignment: .leading) {
            Text(viewModel.advert.title)
                .bold()
                .font(.title)
                .foregroundStyle(.purple)
            
            Text(viewModel.advert.description)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var displayGenres: some View {
        VStack(alignment: .leading) {
            Text("Genres").font(.title3).bold()
            FlowList(data: viewModel.advert.genres)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom)
    }
    
    @ViewBuilder var displaySearchedArtistTypes: some View {
        VStack(alignment: .leading)  {
            Text("Searched").font(.title3).bold()
            FlowList(data: viewModel.advert.searchedArtistTypes)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom)
    }
        
    @ViewBuilder var displayCreatorContacts: some View {
        VStack (alignment: .leading) {
            Text("Creator contacts")
                .bold()
                .font(.title3)
                .padding(.bottom, 8)
            
            ContactsList(contacts: viewModel.advert.contacts)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
    }
    
    @ViewBuilder var displayLocation: some View {
        VStack (alignment: .leading) {
            Text("Location")
                .bold()
                .font(.title3)
                .padding(.bottom, 8)

            VStack {
                MapView(
                    mapItems: [
                        LocationService.getMapItem(location: viewModel.advert.location)
                    ]
                )
                .frame(height: 300)
                LocationText(location: viewModel.advert.location)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder var displayMenu: some View {
        if JWTService.shared.extractEmail() == viewModel.advert.creator.email {
            Menu {
                Button("Delete", role: .destructive) { viewModel.deleteAdvert() }
                Button("Edit") { viewModel.editAdvert() }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdvertDetailView(
            viewModel: AdvertDetailViewModel(
                advert: Advert(
                    id: 0,
                    title: "Searching for a guitarist",
                    description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    location: Location(
                        country: "country", city: "city", administrativeArea: "area", lat: 63, lon: 53
                    ),
                    genres: [Genre (id: 0, name: "METAL"), Genre(id: 1, name: "ROCK")],
                    searchedArtistTypes: [ArtistType(id: 0, name: "GUITARIST"), ArtistType(id: 1, name: "DRUMMER")],
                    creator: UserDetails(id: 0, username: "Username", email: "email@email"),
                    contacts: Contacts(phoneNumber: "+35949494949"),
                    createdAt: Date.now),
                store: AdvertStore()
            )
        )
    }
}
