//
//  AdvertCreateUpdateView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertCreateEditView: View {
    @ObservedObject var viewModel: AdvertCreateEditViewModel
    
    var body: some View {
        LoadingView(loading: viewModel.loading) {
            Form {
                displayTextSection
                displayGenresAndArtistTypesSelectSection
            }
        }
        .task {
            guard viewModel.availableGenres.isEmpty || viewModel.availableArtistTypes.isEmpty else { return }
            viewModel.fetchGenresAndArtistTypes()
        }
        .refreshable {
            viewModel.fetchGenresAndArtistTypes()
        }
        .navigationTitle(viewModel.modifyAction == .create ? "Create Advert" : "Edit Advert")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                displayDoneButton
            }
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

private extension AdvertCreateEditView {
    @ViewBuilder var displayTextSection: some View {
        Section {
            TextField("Title", text: $viewModel.title)
                .font(.title2)
                .foregroundStyle(.purple)
                .bold()
            CharacterCountTextEditor("Description", text: $viewModel.description, maxChars: 5000)
                .frame(height: 300)
        }
    }
    
    @ViewBuilder var displayGenresAndArtistTypesSelectSection: some View {
        Section {
            MultiSelector(
                label: Text("Genres"),
                options: viewModel.availableGenres,
                optionToString: { $0.description },
                selected: $viewModel.genres
            )
            
            MultiSelector(
                label: Text("Searched Artist Types"),
                options: viewModel.availableArtistTypes,
                optionToString: { $0.description },
                selected: $viewModel.searchedArtistTypes
            )
        }
    }
    
    @ViewBuilder var displayDoneButton: some View {
        Button(viewModel.modifyAction == .create ? "Create" : "Done") {
            viewModel.modify()
        }
        .disabled(!viewModel.validate)
    }
}

#Preview {
    NavigationStack {
        AdvertCreateEditView(viewModel: AdvertCreateEditViewModel(store: AdvertStore()))
    }
}
