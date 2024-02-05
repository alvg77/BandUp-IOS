//
//  AdvertModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

class AdvertModel: ObservableObject {
    typealias OnComplete = () -> Void
    typealias OnCompleteValue = (Advert) -> Void
    typealias HandleError = (APIError?) -> Void
    
    @Published var adverts: [Advert] = []  
    @Published var genres: [Genre] = []
    @Published var artistTypes: [ArtistType] = []
   
    var advertFilter: AdvertFilter?
    
    private let pageSize = 10
    
    func applyFilter(advertFilter: AdvertFilter?, onComplete: @escaping OnComplete, handleError: @escaping HandleError) {
        self.advertFilter = advertFilter
        fetchAdverts(appending: false, pageNo: 0, onComplete: onComplete, handleError: handleError)
    }
    
    func fetchAdverts(appending: Bool, pageNo: Int, onComplete: OnComplete? = nil, handleError: @escaping HandleError) {
        AdvertService.shared.getAll(pageNo: pageNo, pageSize: pageSize, filter: advertFilter) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let adverts):
                    if appending {
                        self?.adverts.append(contentsOf: adverts)
                    } else {
                        self?.adverts = adverts
                    }
                    onComplete?()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func fetchAdvert(advertId: Int, onComplete: @escaping OnCompleteValue, handleError: @escaping HandleError) {
        AdvertService.shared.getById(advertId: advertId) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let advert):
                    if let index = self?.adverts.firstIndex(where: { $0.id == advertId }) {
                        self?.adverts[index] = advert
                    }
                    onComplete(advert)
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func createAdvert(_ new: CreateUpdateAdvert, onComplete: @escaping OnComplete, handleError: @escaping HandleError) {
        AdvertService.shared.create(advertCreateRequest: new) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let advert):
                    self?.adverts.insert(advert, at: 0)
                    onComplete()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func updateAdvert(_ update: CreateUpdateAdvert, id: Int, onComplete: @escaping OnCompleteValue, handleError: @escaping HandleError) {
        AdvertService.shared.update(advertId: id, advertUpdateRequest: update) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let advert):
                    if let index = self?.adverts.firstIndex(where: { $0.id == id }) {
                        self?.adverts[index] = advert
                    }
                    onComplete(advert)
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func deleteAdvert(id: Int, onComplete: @escaping OnComplete, handleError: @escaping HandleError) {
        AdvertService.shared.delete(advertId: id) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success:
                    if let index = self?.adverts.firstIndex(where: { $0.id == id }) {
                        self?.adverts.remove(at: index)
                    }
                    onComplete()
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    func fetchGenresAndArtistTypes(handleError: @escaping HandleError) {
        fetchGenres(handleError: handleError)
    }
    
    private func fetchGenres(handleError: @escaping HandleError) {
        GenreService.shared.getGenres { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let genres):
                    self?.genres = genres
                    handleError(nil)
                    if let artistTypes = self?.artistTypes, artistTypes.isEmpty {
                        self?.fetchArtistTypes(handleError: handleError)
                    }
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
    
    private func fetchArtistTypes(handleError: @escaping HandleError) {
        ArtistTypeService.shared.getArtistTypes { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let artistTypes):
                    self?.artistTypes = artistTypes
                    handleError(nil)
                case .failure(let error):
                    handleError(error)
                }
            }
        }
    }
}
