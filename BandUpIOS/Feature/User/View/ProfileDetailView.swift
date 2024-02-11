//
//  UserDetailView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import SwiftUI

struct ProfileDetailView: View {
    @ObservedObject var viewModel: ProfileDetailViewModel
    @State var deletionAlert = false
    
    var body: some View {
        LoadingView(loading: viewModel.loading) {
            ScrollView {
                userTop
                bio.padding(.top)
                Divider()
                    .padding(.vertical, 8)
                genres
                Divider()
                    .padding(.vertical, 8)
                contacts
                Divider()
                    .padding(.vertical, 8)
                location
            }
            .scrollIndicators(.hidden)
        }
        .padding(.all)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard viewModel.user == nil else { return }
            viewModel.refreshUserDetails()
        }
        .refreshable {
            viewModel.refreshUserDetails()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if JWTService.shared.extractEmail() == viewModel.user?.email {
                    profileMenu
                }
            }
        }
        .alert("Confirm Deletion", isPresented: $deletionAlert, actions: {
            Button("Delete", role: .destructive) {
                viewModel.deleteProfile()
            }
            
            Button("Cancel", role: .cancel) {
                deletionAlert.toggle()
            }
        }, message: {
            Text("Are you sure that you want to delete your account?")
        })
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

private extension ProfileDetailView {
    @ViewBuilder var userTop: some View {
        HStack {
            UserProfilePicture(imageKey: viewModel.user?.profilePictureKey, diameter: 80)
            VStack (alignment: .leading) {
                Text(viewModel.user?.username ?? "").bold()
                Text(viewModel.user?.artistType.description ?? "").font(.footnote).foregroundStyle(.purple)
            }
            Spacer()
            VStack {
                Text("Member since").bold().font(.caption2)
                Text(viewModel.user?.createdAt.formatted() ?? "").font(.caption2)
            }
            .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder var bio: some View {
        VStack (alignment: .leading) {
            Text("Bio")
                .font(.title3)
                .bold()
            Text(viewModel.user?.bio ?? "")
                .multilineTextAlignment(.leading)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var genres: some View {
        VStack (alignment: .leading) {
            Text("Genres")
                .font(.title3)
                .bold()
            FlowList(data: viewModel.user?.genres ?? [])
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var contacts: some View {
        VStack (alignment: .leading){
            Text("Contacts")
                .font(.title3)
                .bold()
            ContactsList(contacts: viewModel.user?.contacts ?? Contacts())
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder var location: some View {
        VStack(alignment: .leading) {
            Text("Location")
                .font(.title3)
                .bold()
            VStack {
                if let user = viewModel.user {
                    MapView(mapItems: [LocationService.getMapItem(location: user.location)])
                        .frame(height: 300)
                    LocationText(location: user.location)
                } else {
                    MapView(mapItems: [])
                }
            }
        }
    }
    
    @ViewBuilder var profileMenu: some View {
        Menu {
            Button {
                viewModel.logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                Text("Logout")
            }
            
            Button {
                viewModel.editProfile()
            } label: {
                Image(systemName: "pencil.and.scribble")
                Text("Edit")
            }
            
            Button(role: .destructive) {
                deletionAlert.toggle()
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

#Preview {
    let viewModel = ProfileDetailViewModel()
    viewModel.user = User(id: 0, username: "Username", email: "user@email.mail", artistType: ArtistType(id: 0, name: "GUITARIST"), genres: [Genre(id: 0, name: "METAL")], bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", location: Location(country: "Country", city: "City", administrativeArea: "Area", lat: 32, lon: 23), contacts: Contacts(phoneNumber: "+3598988989"), createdAt: Date.now)
    return NavigationStack { ProfileDetailView(viewModel: viewModel) }.tint(.purple)
}
