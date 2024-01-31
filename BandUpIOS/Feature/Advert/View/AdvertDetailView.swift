//
//  AdvertDetailView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var selected: [ArtistType] = []
    
    var title: String
    var description: String
    var location: Location
    var genres: [Genre]
    var searchedArtistTypes: [ArtistType]
    var createor: UserDetails
    var contacts: Contacts
    var createdAt: Date

    var body: some View {
        ScrollView {
            advertDetails
            genresAndArtistTypes
            creatorDetails
            creatorLocation
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                
            }
        }
    }
}

private extension AdvertDetailView {
    @ViewBuilder var advertDetails: some View {
        VStack(alignment: .leading) {
            VStack (alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.purple)
                Text(createdAt.formatted())
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Divider()
                .frame(height: 4)
            
            Text(description)
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom)
        .padding(.all, 15)
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
        .padding(.horizontal, 2)
        .padding(.bottom)
    }
    
    @ViewBuilder var genresAndArtistTypes: some View {
        HStack {
            VStack {
                Text("Genres").font(.subheadline).bold()
                FlowList(data: genres)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack {
                Text("Searched").font(.subheadline).bold()
                FlowList(data: searchedArtistTypes)
                
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.all, 15)
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
        .padding(.horizontal, 2)
        .padding(.bottom)
    }
    
    @ViewBuilder var creatorDetails: some View {
        VStack {
            UserProfilePicture(diameter: 100)
            Text(createor.username).bold()
            
            Spacer().frame(height: 24)
            
            if let email = contacts.contactsEmail {
                HStack {
                    Image(systemName: "envelope").foregroundStyle(.purple).bold()
                    Text(email)
                }
                .padding(.bottom, 4)
            }
            
            if let number = contacts.phoneNumer {
                HStack {
                    Image(systemName: "phone").foregroundStyle(.purple).bold()
                    Text(number)
                }
                .padding(.bottom, 4)
            }
            
            if let website = contacts.website {
                HStack {
                    Image(systemName: "globe").foregroundStyle(.purple).bold()
                    Text(website)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 15)
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
        .padding(.horizontal, 2)
        .padding(.bottom)
    }
    
    @ViewBuilder var creatorLocation: some View {
        Text("Location")
    }
    
    @ViewBuilder var menu: some View {
        Menu {
            Button("Delete", role: .destructive) { }
            Button("Edit") { }
        } label: {
            Image(systemName: "ellipsis")
        }

    }
}

#Preview {
    AdvertDetailView(
        title: "Searching for a guitarist",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        location: Location(),
        genres: [Genre (id: 0, name: "METAL"), Genre(id: 1, name: "ROCK")],
        searchedArtistTypes: [ArtistType(id: 0, name: "GUITARIST"), ArtistType(id: 1, name: "DRUMMER")],
        createor: UserDetails(id: 0, username: "Username", email: "email@email"),
        contacts: Contacts(phoneNumer: "+359893690922", contactsEmail: "contacts@band.com", website: "bandwebsite.com"),
        createdAt: Date.now
    )
}
