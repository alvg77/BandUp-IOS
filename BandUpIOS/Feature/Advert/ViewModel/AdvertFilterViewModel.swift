//
//  AdvertFilterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

class AdvertFilterViewModel: ObservableObject {
    @Published var genres: [Genre] = []
    @Published var searchedArtistTypes: [ArtistType] = []
    @Published var error: APIError?
    
    var onComplete: (() -> Void)?
    var toAuth: (() -> Void)?
    
    func fetchGenres() {
        GenreService.shared.getGenres { [weak self] completion in
            switch completion {
            case .success(let genres):
                self?.genres = genres
                self?.error = nil
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    func fetchArtistTypes() {
        ArtistTypeService.shared.getArtistTypes { [weak self] completion in
            switch completion {
            case .success(let artistTypes):
                self?.searchedArtistTypes = artistTypes
                self?.error = nil
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
