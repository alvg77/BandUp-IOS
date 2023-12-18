//
//  RegisterGenreSelectViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine

class GenreSelectViewModel: ObservableObject, RegisterStepViewModel {
    @Published var genres: [Genre] = []
    @Published var selected: [Genre] = []
    @Published var errorMessage = ""
    
    var validateStep: Bool {
        !selected.isEmpty
    }
    
    func getGenres() {
        GenreFetchService()
            .getGenres { [weak self] completion in
                DispatchQueue.main.async {
                    switch completion {
                    case .success(let genres):
                        self?.genres = genres
                    case .failure(let error):
                        self?.errorMessage = error.errorDescription
                    }
                }
            }
    }
}
