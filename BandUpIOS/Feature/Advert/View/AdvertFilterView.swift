//
//  AdvertFilterView.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import SwiftUI

struct AdvertFilterView: View {
    @ObservedObject var viewModel: AdvertFilterViewModel

    var body: some View {

        Form {
            displayLocationSection
            displayGenresAndArtistTypesSection
        }
        .task {
            guard viewModel.filter.genres.isEmpty || viewModel.filter.searchedArtistTypes.isEmpty else { return }
            viewModel.fetchGenresAndArtistTypes()
        }
        .refreshable {
            viewModel.fetchGenresAndArtistTypes() 
        }
        .navigationTitle("Filter Adverts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    displayClearButton
                    displayApplyFilterButton
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

private extension AdvertFilterView {
    @ViewBuilder var displayLocationSection: some View {
        Section("Filter by location") {
            VStack {
                SearchBar(text: $viewModel.searchQuery, onSearchButtonClicked: viewModel.searchForCity)
                MapView(mapItems: viewModel.mapItems)
                    .frame(height: 300)
            }.padding(.vertical, 4)
        }
    }
    
    @ViewBuilder var displayGenresAndArtistTypesSection: some View {
        Section("Filter by genres and artist types") {
            MultiSelector(
                label: Text("Genres"),
                options: viewModel.availableGenres,
                optionToString: { $0.description },
                selected: $viewModel.filter.genres
            )
            
            MultiSelector(
                label: Text("Searched Artist Types"),
                options: viewModel.availableArtistTypes,
                optionToString: { $0.description },
                selected: $viewModel.filter.searchedArtistTypes
            )
        }
    }
    
    @ViewBuilder var displayClearButton: some View {
        Button("Clear") {
            viewModel.clearFilter()
        }
        .disabled(!viewModel.clearEnabled)
    }
    
    @ViewBuilder var displayApplyFilterButton: some View {
        Button("Apply") {
            viewModel.applyFilter()
       }
        .disabled(!viewModel.applyEnabled)
    }
}

#Preview {
    AdvertFilterView(viewModel: AdvertFilterViewModel(model: AdvertModel()))
}
