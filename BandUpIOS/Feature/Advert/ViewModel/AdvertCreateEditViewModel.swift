//
//  AdvertCreateUpdateViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

class AdvertCreateEditViewModel: ObservableObject {
    var advertId: Int?
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var genres: [Genre] = []
    @Published var searchedArtistTypes: [ArtistType] = []
    @Published var availableGenres: [Genre] = []
    @Published var availableArtistTypes: [ArtistType] = []
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    var modifyAction: ModifyAction
    
    private var store: AdvertStore
    private var cancellables = Set<AnyCancellable>()
    
    var toAuth: (() -> Void)?
    var onSuccess: (() -> Void)?
    
    var validate: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !genres.isEmpty &&
        !searchedArtistTypes.isEmpty
    }
    
    var observeGenresChanges: AnyCancellable {
        self.store.$genres.sink { [weak self] in
            self?.availableGenres = $0
        }
    }
    
    var observeArtistTypesChanges: AnyCancellable {
        self.store.$artistTypes.sink { [weak self] in
            self?.availableArtistTypes = $0
        }
    }
    
    init(store: AdvertStore) {
        self.advertId = nil
        self.modifyAction = .create
        self.store = store
        self.availableGenres = self.store.genres
        self.availableArtistTypes = self.store.artistTypes
        observeGenresChanges.store(in: &cancellables)
        observeArtistTypesChanges.store(in: &cancellables)
    }
    
    init(advert: Advert, store: AdvertStore) {
        self.advertId = advert.id
        self.title = advert.title
        self.description = advert.description
        self.genres = advert.genres
        self.searchedArtistTypes = advert.searchedArtistTypes
        self.modifyAction = .edit
        self.store = store
        self.availableGenres = self.store.genres
        self.availableArtistTypes = self.store.artistTypes
        observeGenresChanges.store(in: &cancellables)
        observeArtistTypesChanges.store(in: &cancellables)
    }
    
    func modify() {
        loading = .loading
        if modifyAction == .create {
            create() 
        } else if modifyAction == .edit {
            edit()
        }
    }
    
    func create() {
        store.createAdvert(
            CreateEditAdvert(
                title: title,
                description: description,
                genreIds: genres.map { $0.id },
                searchedArtistTypeIds: searchedArtistTypes.map { $0.id }
            ),
            onComplete: { [weak self] in self?.loading = .notLoading },
            onSuccess: onSuccess ?? {},
            handleError: handleError
        )
    }
    
    func edit() {
        store.editAdvert(
            CreateEditAdvert(
                title: title,
                description: description,
                genreIds: genres.map { $0.id },
                searchedArtistTypeIds: searchedArtistTypes.map { $0.id }
            ),
            id: advertId!,
            onComplete: { [weak self] in self?.loading = .notLoading },
            onSuccess: onSuccess ?? {},
            handleError: handleError
        )
    }

    func fetchGenresAndArtistTypes() {
        loading = .loading
        store.fetchGenresAndArtistTypes(onComplete: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
