//
//  AdvertListViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation
import Combine

class AdvertListViewModel: ObservableObject {
    @Published var adverts: [Advert] = []
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var store: AdvertStore
    private var cancellables = Set<AnyCancellable>()
    private var pageNo = 0
    
    var toAuth: (() -> Void)?
    var navigateToAdvertDetail: ((Advert) -> Void)?
    var navigateToCreateAdvert: (() -> Void)?
    var navigateToFilterAdverts: (() -> Void)?
    var navigateToProfileDetail: ((Int) -> Void)?
    
    var observeAdvertsUpdates: AnyCancellable {
        self.store.$adverts.sink { [weak self] in
            self?.adverts = $0
        }
    }
    
    init(store: AdvertStore) {
        self.store = store
        observeAdvertsUpdates.store(in: &cancellables)
    }
    
    func fetchAdverts() {
        loading = .loading
        pageNo = 0
        store.fetchAdverts(appending: false, pageNo: pageNo, onComplete: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    func fetchNextPage(advert: Advert) {
        guard advert.id == adverts.last?.id else {
            return
        }
        pageNo += 1
        store.fetchAdverts(appending: true, pageNo: pageNo, handleError: handleError)
    }
    
    func createAdvert() {
        navigateToCreateAdvert?()
    }
    
    func advertDetail(advert: Advert) {
        navigateToAdvertDetail?(advert)
    }
    
    func filterAdverts() {
        navigateToFilterAdverts?()
    }
    
    func profileDetail(advert: Advert) {
        navigateToProfileDetail?(advert.creator.id)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
