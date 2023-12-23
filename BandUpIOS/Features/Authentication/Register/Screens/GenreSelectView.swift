//
//  RegisterGenreSelectView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI

struct GenreSelectView: View {
    @ObservedObject var viewModel: GenreSelectViewModel
    
    var body: some View {
        ScrollView {
            Text("Genres")
                .bold()
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            Text("In what genres do you perform?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            if let error = viewModel.error {
                ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to fetch the available genres.")
            }
            
            genreSelector
            continueButton
        }
        .padding(.all)
        .onAppear {
            if viewModel.genres.isEmpty {
                viewModel.getGenres()
            }
        }
        .refreshable {
            viewModel.getGenres()
        }
    }
}

extension GenreSelectView {
    @ViewBuilder var genreSelector: some View {
        FlowSelector(data: viewModel.genres, selected: $viewModel.selected)
    }
    
    @ViewBuilder var continueButton: some View {
        Button {
            viewModel.next?()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ShrinkingButton())
        .disabled(!viewModel.validateStep)
    }
}

#Preview {
    GenreSelectView(viewModel: GenreSelectViewModel())
}
