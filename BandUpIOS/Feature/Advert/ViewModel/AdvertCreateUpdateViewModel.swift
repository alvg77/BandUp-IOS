//
//  AdvertCreateUpdateViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

class AdvertCreateUpdateViewModel: ObservableObject {
    var advertId: Int?
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var genres: [Genre] = []
    @Published var searchedArtistTypes: [ArtistType] = []
    @Published var error: APIError?
    
    private var model: AdvertModel
    
    var toAuth: (() -> Void)?
    var onCreateComplete: (() -> Void)?
    var onUpdateComplete: ((Advert) -> Void)?
    
    init(model: AdvertModel) {
        advertId = nil
        self.model = model
    }
    
    init(advert: Advert, model: AdvertModel) {
        advertId = advert.id
        title = advert.title
        description = advert.description
        genres = advert.genres
        searchedArtistTypes = advert.searchedArtistTypes
        self.model = model
    }
    
    
    func modify() {
        
    }
    
    func create() {
        model.createAdvert(
            CreateUpdateAdvert(
                title: title,
                description: description,
                genreIds: genres.map { $0.id },
                searchedArtistTypeIds: searchedArtistTypes.map { $0.id }
            ),
            onComplete: onCreateComplete ?? {},
            handleError: handleError
        )
    }
    
    func update() {
        model.updateAdvert(
            CreateUpdateAdvert(
                title: title,
                description: description,
                genreIds: genres.map { $0.id },
                searchedArtistTypeIds: searchedArtistTypes.map { $0.id }
            ),
            id: advertId!,
            onComplete: onUpdateComplete ?? {_ in},
            handleError: handleError
        )
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
