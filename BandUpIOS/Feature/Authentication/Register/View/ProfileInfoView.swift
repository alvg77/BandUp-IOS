//
//  ProfileInfo.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI

struct ProfileInfoView: View {
    @ObservedObject var viewModel: ProfileInfoViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                Text("Profile Info")
                    .bold()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 4)
                
                Text("Tell us a little about yourself.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                if let error = viewModel.error {
                    ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to fetch the available artist types.")
                        .padding(.bottom)
                }
                
                artistTypePicker
                bio
                continueButton
            }
            
            if viewModel.loading == .loading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
        .task {
            if viewModel.artistTypes.isEmpty {
                viewModel.getArtistTypes()
            }
        }
        .refreshable {
            viewModel.getArtistTypes()
        }
    }
}

private extension ProfileInfoView {
    @ViewBuilder private var artistTypePicker: some View {
        HStack {
            Text("Artist Type")
            Spacer()
            Picker("Artist Type", selection: $viewModel.artistType) {
                Text("None").tag(Optional<ArtistType>(nil))
                ForEach(viewModel.artistTypes) {
                    Text($0.description).tag(Optional($0))
                }
            } 
            .pickerStyle(.menu)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(.systemGray6)))
        .padding(.bottom, 8)
    }
    
    @ViewBuilder private var bio: some View {
        TextField("Bio", text: $viewModel.bio, axis: .vertical)
            .lineLimit(8, reservesSpace: true)
            .textFieldStyle(RoundBorderTextFieldStyle())
            .padding(.vertical)
    }
    
    @ViewBuilder private var continueButton: some View {
        Button {
            viewModel.next()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundButton())
        .disabled(!viewModel.validateStep)
    }
}

#Preview {
    ProfileInfoView(viewModel: ProfileInfoViewModel(next: {}))
}
