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
    
    private let onDelete: () -> Void
    private let navigateToEditAdvert: (Advert) -> Void
    private let navigateToProfileDetail: (Int) -> Void
    
    var observeAdvertUpdates: AnyCancellable {
        self.store.$adverts.sink { [weak self] adverts in
            if let advert = adverts.first(where: { $0.id == self?.advert.id }) {
                self?.advert = advert
            }
        }
    }
    
    init(
        advert: Advert,
        store: AdvertStore,
        onDelete: @escaping () -> Void,
        navigateToEditAdvert: @escaping (Advert) -> Void,
        navigateToProfileDetail: @escaping (Int) -> Void
    ) {
        self.advert = advert
        self.store = store
        self.onDelete = onDelete
        self.navigateToEditAdvert = navigateToEditAdvert
        self.navigateToProfileDetail = navigateToProfileDetail
        observeAdvertUpdates.store(in: &cancellables)
    }
    
    func editAdvert() {
        navigateToEditAdvert(advert)
    }
    
    func deleteAdvert() {
        loading = .loading
        store.deleteAdvert(id: advert.id,onSuccess: { [weak self] in
            self?.loading = .notLoading
            self?.onDelete()
        }, handleError: handleError)
    }
    
    func refreshAdvert() {
        loading = .loading
        store.fetchAdvert(advertId: advert.id, onSuccess: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    func profileDetail() {
        navigateToProfileDetail(advert.creator.id)
    }
    
    private func handleError(error: APIError?) {
        self.loading = .notLoading
        self.error = error
    }
}
