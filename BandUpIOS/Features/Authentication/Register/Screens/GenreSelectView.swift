//
//  RegisterGenreSelectView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import SwiftUI

struct GenreSelectView: View {
    var next: (() -> Void)?
    @ObservedObject var viewModel: GenreSelectViewModel
    
    var body: some View {
        if viewModel.errorMessage != "" {
            ErrorMessage(errorMessage: viewModel.errorMessage)
        }
        
        FlowSelector(data: viewModel.genres, selected: $viewModel.selected)
            .padding(.all)
            .onAppear {
                if viewModel.genres.isEmpty {
                    viewModel.getGenres()
                }
            }
            .opacity(viewModel.genres.isEmpty && viewModel.errorMessage.isEmpty ? 0.5 : 1)
        
        Button {
            next?()
        } label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ShrinkingButton())
        .disabled(!viewModel.validateStep)
    }
}

#Preview {
    GenreSelectView(next: {}, viewModel: GenreSelectViewModel())
}
