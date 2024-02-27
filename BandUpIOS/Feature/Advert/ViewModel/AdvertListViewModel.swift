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
    
    private let navigateToAdvertDetail: (Advert) -> Void
    private let navigateToCreateAdvert: () -> Void
    private let navigateToFilterAdverts: () -> Void
    private let navigateToProfileDetail: (Int) -> Void
    
    var observeAdvertsUpdates: AnyCancellable {
        self.store.$adverts.sink { [weak self] in
            self?.adverts = $0
        }
    }
    
    init(
        store: AdvertStore,
        navigateToAdvertDetail: @escaping (Advert) -> Void,
        navigateToCreateAdvert: @escaping () -> Void,
        navigateToFilterAdverts: @escaping () -> Void,
        navigateToProfileDetail: @escaping (Int) -> Void
    ) {
        self.store = store
        self.navigateToAdvertDetail = navigateToAdvertDetail
        self.navigateToCreateAdvert = navigateToCreateAdvert
        self.navigateToFilterAdverts = navigateToFilterAdverts
        self.navigateToProfileDetail = navigateToProfileDetail
        observeAdvertsUpdates.store(in: &cancellables)
    }
    
    func fetchAdverts() {
        loading = .loading
        pageNo = 0
        store.fetchAdverts(appending: false, pageNo: pageNo, onSuccess: { [weak self] in self?.loading = .notLoading }, handleError: handleError)
    }
    
    func fetchNextPage(advert: Advert) {
        guard advert.id == adverts.last?.id else {
            return
        }
        pageNo += 1
        store.fetchAdverts(appending: true, pageNo: pageNo, handleError: handleError)
    }
    
    func createAdvert() {
        navigateToCreateAdvert()
    }
    
    func advertDetail(advert: Advert) {
        navigateToAdvertDetail(advert)
    }
    
    func filterAdverts() {
        navigateToFilterAdverts()
    }
    
    func profileDetail(advert: Advert) {
        navigateToProfileDetail(advert.creator.id)
    }
    
    private func handleError(error: APIError?) {
        self.loading = .notLoading
        self.error = error
    }
}
