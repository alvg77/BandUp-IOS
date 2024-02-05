//
//  AdvertDetailViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

class AdvertViewModel: ObservableObject {
    @Published var advert: Advert
    @Published var error: APIError?
    
    private var model: AdvertModel
    
    var toAuth: (() -> Void)?
    var navigateToUpdateAdvert: ((Advert, @escaping (Advert) -> Void) -> Void)?
    var onDelete: (() -> Void)?
    
    init(advert: Advert, model: AdvertModel) {
        self.advert = advert
        self.model = model
    }
    
    func updateAdvert() {
        navigateToUpdateAdvert?(advert, onCompleteValue)
    }
    
    func deleteAdvert() {
        model.deleteAdvert(id: advert.id, onComplete: onDelete ?? {}, handleError: handleError)
    }
    
    func fetchAdvert() {
        model.fetchAdvert(advertId: advert.id, onComplete: onCompleteValue, handleError: handleError)
    }
    
    private func onCompleteValue(advert: Advert) {
        self.advert = advert
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
