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
    var location: Location
    var genres: [Genre]
    var searchedArtistTypes: [ArtistType]
    var creator: UserDetails
    var createdAt: Date
    
    var profileDetail: () -> Void
    
    var body: some View {
        HStack {
            VStack (alignment: .leading){
                displayCreator
                Text(title)
                    .font(.title2)
                    .bold()
                displayGenres
                Divider()
                displayDate
                    .padding(.top, 4)
            }
            Spacer()
        }
        .cardBackground()
    }
}

private extension AdvertRowView {
    @ViewBuilder var displayCreator: some View {
        HStack {
            UserProfilePicture(imageKey: creator.profilePictureKey, diameter: 40)
            VStack (alignment: .leading) {
                Text(creator.username)
                HStack (spacing: 0) {
                    Image(systemName: "mappin")
                    Text(getLocationString())
                }
                .bold()
                .foregroundStyle(.purple)
                .font(.footnote)
            }
        }
        .onTapGesture {
            profileDetail()
        }
    }
    
    @ViewBuilder var displayGenres: some View {
        HStack {
            VStack(alignment: .leading) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            VStack(alignment: .leading) {
                Text("Searched").font(.subheadline).bold()
                HStack {
                    Text(searchedArtistTypes.first?.description ?? "")
                        .foregroundStyle(.white)
                        .padding(.all, 6)
                        .background(.purple)
                        .clipShape(Capsule())
                    if searchedArtistTypes.count > 1 {
                        Text("+\(searchedArtistTypes.count - 1)")
                            .foregroundStyle(.white)
                            .padding(.all, 6)
                            .background(.purple)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private func getLocationString() -> String {
        let city = location.city != nil ? location.city! + ", " : ""
        let administrativeArea = location.administrativeArea != nil && location.administrativeArea != city ? location.administrativeArea! + ", " : ""
        let country = location.country != nil ? location.country! : ""
        
        return city + administrativeArea + country
    }
}

#Preview {
    AdvertRowView(
        title: "Searching for a bass player",
        location: Location(country: "Bulgaria", city: "Sofia", administrativeArea: "Sofia-city", lat: 0, lon: 0),
        genres: [Genre(id: 0, name: "Metal"), Genre(id: 1, name: "Rock")],
        searchedArtistTypes: [ArtistType(id: 0, name: "Guitarist"), ArtistType(id: 1, name: "Bassist")],
        creator: UserDetails(id: 0, username: "username", email: "username@email.com"),
        createdAt: Date.now
    ) {}
}
