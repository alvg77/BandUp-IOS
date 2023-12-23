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
            if let error = viewModel.error {
                ErrorMessage(errorMessage: error.errorDescription ?? "An error occured while trying to fetch the available genres.")
            }
            
            FlowSelector(data: viewModel.genres, selected: $viewModel.selected)
                .padding(.all)
            
            Button {
                viewModel.next?()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ShrinkingButton())
            .disabled(!viewModel.validateStep)
        }
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

#Preview {
    GenreSelectView(viewModel: GenreSelectViewModel())
}
