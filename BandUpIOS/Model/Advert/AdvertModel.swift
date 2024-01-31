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
    
    func fetchAdverts(appending: Bool, pageNo: Int, pageSize: Int, handleError: @escaping HandleError) {
        AdvertService.shared.getAll(pageNo: pageNo, pageSize: pageSize) { [weak self] completion in
            switch completion {
            case .success(let adverts):
                if appending {
                    self?.adverts.append(contentsOf: adverts)
                } else {
                    self?.adverts = adverts
                }
                handleError(nil)
            case .failure(let error):
                handleError(error)
            }
        }
    }
    
    func fetchAdvert(advertId: Int, onComplete: @escaping OnCompleteValue, handleError: @escaping HandleError) {
        AdvertService.shared.getById(advertId: advertId) { [weak self] completion in
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
    
    func createAdvert(_ new: CreateUpdateAdvert, onComplete: @escaping OnComplete, handleError: @escaping HandleError) {
        AdvertService.shared.create(advertCreateRequest: new) { [weak self] completion in
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
    
    func updateAdvert(_ update: CreateUpdateAdvert, id: Int, onComplete: @escaping OnCompleteValue, handleError: @escaping HandleError) {
        AdvertService.shared.update(advertId: id, advertUpdateRequest: update) { [weak self] completion in
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
    
    func deleteAdvert(id: Int, onComplete: @escaping OnComplete, handleError: @escaping HandleError) {
        AdvertService.shared.delete(advertId: id) { [weak self] completion in
            switch completion {
            case .success:
                if let index = self?.adverts.firstIndex(where: { $0.id == id }) {  
                    self?.adverts.remove(at: index)
                }
                handleError(nil)
            case .failure(let error):
                handleError(error)
            }
        }
    }
}
