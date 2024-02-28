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
        ZStack {
            ScrollView {
                Text("Genres")
                    .bold()
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 4)
                
                Text("In what genres do you perform?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                if let error = viewModel.error {
                    ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to fetch the available genres.")
                }
                
                genreSelector
                    .padding(.bottom)
                continueButton
            }
            
            if viewModel.loading == .loading {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2)
            }
        }
        .padding(.all)
        .task {
            if viewModel.genres.isEmpty {
                viewModel.getGenres()
            }
        }
        .refreshable {
            viewModel.getGenres()
        }
    }
}

private extension GenreSelectView {
    @ViewBuilder private var genreSelector: some View {
        FlowSelector(data: viewModel.genres, selected: $viewModel.selected)
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
    GenreSelectView(viewModel: GenreSelectViewModel(next: {}))
}
