//
//  AdvertRowView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var content: String
    var location: Location
    var genres: [Genre]
    var searchedArtistTypes: [ArtistType]
    var createor: UserDetails
    var createdAt: Date
    
    var body: some View {
        HStack {
            VStack (alignment: .leading){
                displayCreator
                Text(title)
                    .font(.title2)
                    .bold()
                Text(content)
                    .font(.subheadline)
                    .lineLimit(2)
                displayGenres
                displayDate
                    .padding(.top, 4)
            }
            Spacer()
        }
        .cardBackground()
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }
}

private extension AdvertRowView {
    @ViewBuilder var displayCreator: some View {
        HStack {
            UserProfilePicture(diameter: 40)
            VStack (alignment: .leading) {
                Text(createor.username)
                HStack (spacing: 0) {
                    Image(systemName: "mappin")
                    Text("\(location.postalCode), \(location.city ), \(location.country)")
                }
                .bold()
                .foregroundStyle(.purple)
                .font(.footnote)
                
            }
        }
    }
    
    @ViewBuilder var displayGenres: some View {
        HStack {
            VStack {
                Text("Genres").font(.subheadline).bold()
                HStack {
                    Text(genres.first?.description ?? "")
                        .foregroundStyle(.white)
                        .padding(.all, 6)
                        .background(.purple)
                        .clipShape(Capsule())
                    if genres.count > 1 {
                        Text("+\(genres.count - 1)")
                            .foregroundStyle(.white)
                            .padding(.all, 6)
                            .background(.purple)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack {
                Text("Searched").font(.subheadline).bold()
                HStack {
                    Text(searchedArtistTypes.first?.description ?? "")
                        .foregroundStyle(.white)
                        .padding(.all, 6)
                        .background(.purple)
                        .clipShape(Capsule())
                    if searchedArtistTypes.count > 1 {
                        Text("+\(genres.count - 1)")
                            .foregroundStyle(.white)
                            .padding(.all, 6)
                            .background(.purple)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .frame(height: 80)
    }
    
    @ViewBuilder var displayDate: some View {
        HStack {
            Image(systemName: "calendar")
            Text(createdAt.formatted())
        }
        .font(.caption)
        .foregroundStyle(.gray)
    }
}

#Preview {
    AdvertRowView(
        title: "Searching for a bass player",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        location: Location(country: "Bulgaria", city: "Sofia", postalCode: "1712"),
        genres: [Genre(id: 0, name: "Metal"), Genre(id: 1, name: "Rock")],
        searchedArtistTypes: [ArtistType(id: 0, name: "Guitarist"), ArtistType(id: 1, name: "Bassist")],
        createor: UserDetails(id: 0, username: "username", email: "username@email.com"),
        createdAt: Date.now
    )
}
