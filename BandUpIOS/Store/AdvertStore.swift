//
//  AdvertModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

class AdvertStore: ObservableObject {
    typealias OnSuccess = () -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var adverts: [Advert] = []
    @Published var genres: [Genre] = []
    @Published var artistTypes: [ArtistType] = []
    
    let toAuth: () -> Void
    var advertFilter: AdvertFilter?
    
    private let pageSize = 10
    private var cancellables = Set<AnyCancellable>()
    
    init(toAuth: @escaping () -> Void) {
        self.toAuth = toAuth
    }
    
    func applyFilter(advertFilter: AdvertFilter?, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        self.advertFilter = advertFilter
        fetchAdverts(appending: false, pageNo: 0, onSuccess: onSuccess, handleError: handleError)
    }
    
    func fetchAdverts(
        appending: Bool,
        pageNo: Int,
        userId: Int? = nil,
        onSuccess: OnSuccess? = nil,
        handleError: @escaping HandleError
    ) {
        AdvertService.shared.getAll(
            pageNo: pageNo,
            pageSize: pageSize,
            filter: advertFilter,
            userId: userId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                onSuccess?()
            case .failure(let error):
                self?.checkAuth(error: error)
                handleError(error)
            }
        } receiveValue: { [weak self] in
            if appending {
                self?.adverts.append(contentsOf: $0)
            } else {
                self?.adverts = $0
            }
        }
        .store(in: &cancellables)
    }
    
    func fetchAdvert(advertId: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        AdvertService.shared.getById(advertId: advertId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] advert in
                if let index = self?.adverts.firstIndex(where: { $0.id == advertId }) {
                    self?.adverts[index] = advert
                }
            }
            .store(in: &cancellables)
    }
    
    func createAdvert(_ new: CreateEditAdvert, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        AdvertService.shared.create(advertCreateRequest: new)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] in
                self?.adverts.insert($0, at: 0)
            }
            .store(in: &cancellables)
    }
    
    func editAdvert(_ edit: CreateEditAdvert, id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        AdvertService.shared.edit(advertId: id, advertEditRequest: edit)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] advert in
                if let index = self?.adverts.firstIndex(where: { $0.id == id }) {
                    self?.adverts[index] = advert
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteAdvert(id: Int, onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        AdvertService.shared.delete(advertId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] _ in
                if let index = self?.adverts.firstIndex(where: { $0.id == id }) {
                    self?.adverts.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchGenresAndArtistTypes(onSuccess: @escaping OnSuccess, handleError: @escaping HandleError) {
        GenreService.shared.getGenres()
            .combineLatest(ArtistTypeService.shared.getArtistTypes())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    onSuccess()
                case .failure(let error):
                    self?.checkAuth(error: error)
                    handleError(error)
                }
            } receiveValue: { [weak self] (genres, artistTypes) in
                self?.genres = genres
                self?.artistTypes = artistTypes
            }
            .store(in: &cancellables)
    }
    
    private func checkAuth(error: APIError) {
        if case .unauthorized = error {
            toAuth()
        }
    }
}
