//
//  AdvertCreateUpdateView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI
import MultiPicker

struct AdvertCreateUpdateView: View {
    @ObservedObject var viewModel: AdvertCreateUpdateViewModel
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $viewModel.title)
                    .font(.title2)
                    .foregroundStyle(.purple)
                    .bold()
                CharacterCountTextEditor("Description", text: $viewModel.description, maxChars: 5000)
                    .frame(height: 300)
            }
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
        .task {
            guard viewModel.availableGenres.isEmpty || viewModel.availableArtistTypes.isEmpty else { return }
            viewModel.fetchGenresAndArtistTypes()
        }
        .refreshable {
            viewModel.fetchGenresAndArtistTypes()
        }
        .navigationTitle(viewModel.modifyAction == .create ? "Create Advert" : "Update Advert")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.modifyAction == .create ? "Create" : "Done") {
                    viewModel.modify()
                }
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

#Preview {
    NavigationStack {
        AdvertCreateUpdateView(viewModel: AdvertCreateUpdateViewModel(model: AdvertModel()))
    }
}
