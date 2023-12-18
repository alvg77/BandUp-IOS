//
//  ProfileInfo.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI

struct ProfileInfoView: View {
    var next: (() -> Void)?
    @ObservedObject var viewModel: ProfileInfoViewModel
    
    var body: some View {
        VStack {
            if viewModel.errorMessage != "" {
                ErrorMessage(errorMessage: viewModel.errorMessage)
                    .padding(.bottom)
            }
            
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

            
            TextField("Bio", text: $viewModel.bio, axis: .vertical)
                .lineLimit(8, reservesSpace: true)
                .textFieldStyle(RoundBorderTextFieldStyle())
                .padding(.vertical)
            
            Button {
                next?()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ShrinkingButton())
            .disabled(!viewModel.validateStep)
        }
        .padding(.all)
        .onAppear {
            if viewModel.artistTypes.isEmpty {
                viewModel.getArtistTypes()
            }
        }
    }
}

#Preview {
    ProfileInfoView(next: {}, viewModel: ProfileInfoViewModel())
}
