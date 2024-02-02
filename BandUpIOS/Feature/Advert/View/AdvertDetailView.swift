//
//  AdvertDetailView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: AdvertViewModel

    var body: some View {
        ScrollView {
            displayCreator
            displayAdvertDetails
            displayGenresAndSearchedArtistTypes
            displayCreatorContacts
            displayLocation
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
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
            UserProfilePicture(diameter: 40)
            Text(viewModel.advert.creator.username).bold()
            
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
                .font(.title2)
                .foregroundStyle(.purple)
            
            Text(viewModel.advert.description)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder var displayGenresAndSearchedArtistTypes: some View {
        HStack {
            VStack {
                Text("Genres").font(.subheadline).bold()
                Spacer()
                FlowList(data: viewModel.advert.genres)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack  {
                Text("Searched").font(.subheadline).bold()
                Spacer()
                FlowList(data: viewModel.advert.searchedArtistTypes)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .cardBackground()
        .padding(.bottom, 12)
        .padding(.horizontal, 2)
    }
        
    @ViewBuilder var displayCreatorContacts: some View {
            VStack {
                Text("Creator contacts: ")
                    .bold()
                    .font(.title3)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let email = viewModel.advert.contacts.contactsEmail {
                    HStack {
                        Image(systemName: "envelope").foregroundStyle(.purple).bold()
                        Text(email)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }
                
                if let number = viewModel.advert.contacts.phoneNumer {
                    HStack {
                        Image(systemName: "phone").foregroundStyle(.purple).bold()
                        Text(number)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let website = viewModel.advert.contacts.website {
                    HStack {
                        Image(systemName: "globe").foregroundStyle(.purple).bold()
                        Text(website)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .cardBackground()
            .padding(.bottom, 12)
            .padding(.horizontal, 2)
    }
    
    @ViewBuilder var displayLocation: some View {
        Text("Location")
            .padding(.vertical, 12)
    }
    
    @ViewBuilder var displayMenu: some View {
        if JWTService.shared.extractEmail() == viewModel.advert.creator.email {
            Menu {
                Button("Delete", role: .destructive) { viewModel.deleteAdvert() }
                Button("Edit") { viewModel.updateAdvert() }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

#Preview {
    AdvertDetailView(
        viewModel: AdvertViewModel(
            advert: Advert(
                id: 0,
                title: "Searching for a guitarist",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                location: Location(),
                genres: [Genre (id: 0, name: "METAL"), Genre(id: 1, name: "ROCK")],
                searchedArtistTypes: [ArtistType(id: 0, name: "GUITARIST"), ArtistType(id: 1, name: "DRUMMER")],
                creator: UserDetails(id: 0, username: "Username", email: "email@email"),
                contacts: Contacts(phoneNumer: "+359893690922",
                contactsEmail: "contacts@band.com", website: "bandwebsite.com"),
                createdAt: Date.now),
            model: AdvertModel()
        )
    )
}
