//
//  UserUpdateView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @ObservedObject var viewModel: ProfileEditViewModel
    
    var body: some View {
        ZStack {
            Form {
                profilePicture.padding(.top)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    
                Section {
                    TextField("Username", text: $viewModel.username)
                    TextEditor(text: $viewModel.bio)
                        .frame(height: 240)
                }
                
                Section {
                    artistType
                    genres
                }
                
                Section {
                    contacts
                }
            }
            .scrollIndicators(.hidden)
            
            if viewModel.loading == .loading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                doneButton
            }
        }
        .task {
            viewModel.fetchSelectionData()
        }
        .refreshable {
            viewModel.fetchSelectionData()
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

private extension ProfileEditView {
    @ViewBuilder var profilePicture: some View {
        PhotosPicker(selection: $viewModel.profilePicturePickerItem, matching: .images) {
            Group {
                if let profilePictureUIImage = viewModel.profilePictureUIImage {
                    Image(uiImage: profilePictureUIImage)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    UserProfilePicture(imageKey: viewModel.profilePictureKey, diameter: 150)
                }
            }
            .overlay {
                GeometryReader { geometry in
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.purple)
                        .background(Circle().fill(Color.white))
                        .offset(x: geometry.size.width / 2 + 36, y: geometry.size.height / 2 + 36)
                }
            }
        }
        .tint(.primary)
    }
    
    @ViewBuilder var artistType: some View {
        Picker("Artist Type", selection: $viewModel.artistType) {
            ForEach(viewModel.availableArtistTypes) {
                Text($0.description).tag($0)
            }
        }
        .pickerStyle(.menu)
        .tint(.purple)
    }
    
    @ViewBuilder var genres: some View {
        MultiSelector(label: Text("Genres"), options: viewModel.availableGenres, optionToString: { $0.description }, selected: $viewModel.genres)
            .foregroundStyle(.primary)
    }
    
    @ViewBuilder var contacts: some View {
        Group {
            PhoneNumberTextField(countryCode: $viewModel.phoneNumberCountryCode, countryFlag: $viewModel.phoneNumberCountryFlag, phoneNumber: $viewModel.phoneNumber)
            
            HStack {
                Image(systemName: "envelope")
                TextField("Email", text: $viewModel.contactEmail)
            }
            
            HStack {
                Image(systemName: "globe")
                TextField("Website", text: $viewModel.website)
            }
        }
    }
    
    @ViewBuilder var doneButton: some View {
        Button("Done") {
            viewModel.editProfile()
        }
        .disabled(!viewModel.validate)
    }
}

private extension ProfileEditView {
    func calculateTextHeight(width: CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        textView.text = viewModel.bio
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.sizeToFit()
        return textView.frame.height
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(
            viewModel: ProfileEditViewModel(
                user: User(id: 0, username: "Username", email: "user@email.mail", artistType: ArtistType(id: 0, name: "GUITARIST"), genres: [Genre(id: 1, name: "ROCK")], bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", location: Location(country: "Country", city: "City", administrativeArea: "Area", lat: 32, lon: 23), contacts: Contacts(phoneNumber: "+3598988989"), createdAt: Date.now),
                onSuccess: { _ in },
                toAuth: {}
            )
        )
    }.tint(.purple)
}
