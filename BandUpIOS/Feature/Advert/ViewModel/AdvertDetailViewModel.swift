//
//  AdvertDetailViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

class AdvertDetailViewModel: ObservableObject {
    @Published var advert: Advert
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var store: AdvertStore
    private var cancellables = Set<AnyCancellable>()
    
    var toAuth: (() -> Void)?
    var onDelete: (() -> Void)?
    var navigateToEditAdvert: ((Advert) -> Void)?
    var navigateToProfileDetail: ((Int) -> Void)?
    
    var observeAdvertUpdates: AnyCancellable {
        self.store.$adverts.sink { [weak self] adverts in
            if let advert = adverts.first(where: { $0.id == self?.advert.id }) {
                self?.advert = advert
            }
        }
    }
    
    init(advert: Advert, store: AdvertStore) {
        self.advert = advert
        self.store = store
        observeAdvertUpdates.store(in: &cancellables)
    }
    
    func editAdvert() {
        navigateToEditAdvert?(advert)
    }
    
    func deleteAdvert() {
        loading = .loading
        store.deleteAdvert(id: advert.id, onComplete: { [weak self] in self?.loading = .notLoading }, onSuccess: onDelete ?? {}, handleError: handleError)
    }
    
    func refreshAdvert() {
        loading = .loading
        store.fetchAdvert(advertId: advert.id, onComplete: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    func profileDetail() {
        navigateToProfileDetail?(advert.creator.id)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
