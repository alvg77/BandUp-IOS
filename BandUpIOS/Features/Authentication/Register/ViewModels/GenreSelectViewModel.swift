//
//  RegisterGenreSelectViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine

class GenreSelectViewModel: ObservableObject, RegisterStepViewModel {
    var next: (() -> Void)?
    
    @Published var genres: [Genre] = []
    @Published var selected: [Genre] = []
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
    
    let genreService = GenreFetchService()
    
    var validateStep: Bool {
        !selected.isEmpty
    }
    
    init() {
        getGenres()
    }
    
    func getGenres() {
        genreService.getGenres()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] genres in
                self?.genres = genres
            }
            .store(in: &cancellables)
    }
}
