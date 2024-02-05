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
    @Published var error: APIError?
    
    private var model: AdvertModel
    private var cancellables = Set<AnyCancellable>()
    private var pageNo = 0
    
    var toAuth: (() -> Void)?
    var navigateToAdvertDetail: ((Advert) -> Void)?
    var navigateToCreateAdvert: (() -> Void)?
    var navigateToFilterAdverts: (() -> Void)?
    
    init(model: AdvertModel) {
        self.model = model
        
        self.model.$adverts.sink { [weak self] in
            self?.adverts = $0
        }.store(in: &cancellables)
    }
    
    func fetchAdverts() {
        pageNo = 0
        model.fetchAdverts(appending: false, pageNo: pageNo, handleError: handleError)
    }
    
    func fetchNextPage(advert: Advert) {
        guard advert.id == adverts.last?.id else {
            return
        }
        pageNo += 1
        model.fetchAdverts(appending: true, pageNo: pageNo, handleError: handleError)
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
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
