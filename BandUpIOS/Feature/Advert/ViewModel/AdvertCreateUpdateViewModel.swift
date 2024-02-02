//
//  AdvertCreateUpdateViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

class AdvertCreateUpdateViewModel: ObservableObject {
    var advertId: Int?
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var genres: [Genre] = []
    @Published var searchedArtistTypes: [ArtistType] = []
    @Published var error: APIError?
    
    @Published var availableGenres: [Genre] = []
    @Published var availableArtistTypes: [ArtistType] = []
    
    var modifyAction: ModifyAction
    
    private var model: AdvertModel
    private var cancellables = Set<AnyCancellable>()
    
    var toAuth: (() -> Void)?
    var onCreate: (() -> Void)?
    var onUpdate: ((Advert) -> Void)?
    
    init(model: AdvertModel) {
        self.advertId = nil
        self.modifyAction = .create
        self.model = model
        
        self.model.$genres.sink { [weak self] in
            self?.availableGenres = $0
        }.store(in: &cancellables)
        
        self.model.$artistTypes.sink { [weak self] in
            self?.availableArtistTypes = $0
        }.store(in: &cancellables)
    }
    
    init(advert: Advert, model: AdvertModel) {
        self.advertId = advert.id
        self.title = advert.title
        self.description = advert.description
        self.genres = advert.genres
        self.searchedArtistTypes = advert.searchedArtistTypes
        self.modifyAction = .update
        self.model = model
    }
    
    var validate: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !genres.isEmpty &&
        !searchedArtistTypes.isEmpty
    }
    
    func modify() {
        if modifyAction == .create {
            create() 
        } else if modifyAction == .update {
            update()
        }
    }
    
    func create() {
        model.createAdvert(
            CreateUpdateAdvert(
                title: title,
                description: description,
                genreIds: genres.map { $0.id },
                searchedArtistTypeIds: searchedArtistTypes.map { $0.id }
            ),
            onComplete: onCreate ?? {},
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
            onComplete: onUpdate ?? {_ in},
            handleError: handleError
        )
    }

    func fetchGenresAndArtistTypes() {
        model.fetchGenresAndArtistTypes(handleError: handleError)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
