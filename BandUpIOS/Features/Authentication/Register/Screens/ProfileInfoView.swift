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
        ScrollView {
            Text("Profile Info")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
        .padding(.vertical)
        .padding(.horizontal, 8)
        .onAppear {
            if viewModel.artistTypes.isEmpty {
                viewModel.getArtistTypes()
            }
        }
        .refreshable {
            viewModel.getArtistTypes()
        }
    }
}

extension ProfileInfoView {
    @ViewBuilder var artistTypePicker: some View {
        Picker("Artist Type", selection: $viewModel.artistType) {
            Text("None").tag(Optional<ArtistType>(nil))
            ForEach(viewModel.artistTypes) {
                Text($0.description).tag(Optional($0))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(.systemGray6)))
        .pickerStyle(.navigationLink)
    }
    
    @ViewBuilder var bio: some View {
        TextField("Bio", text: $viewModel.bio, axis: .vertical)
            .lineLimit(8, reservesSpace: true)
            .textFieldStyle(RoundBorderTextFieldStyle())
            .padding(.vertical)
    }
    
    @ViewBuilder var continueButton: some View {
        Button {
            viewModel.next?()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(RoundButton())
        .disabled(!viewModel.validateStep)
    }
}

#Preview {
    ProfileInfoView(viewModel: ProfileInfoViewModel())
}
