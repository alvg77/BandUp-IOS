//
//  AdvertDetailViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 31.01.24.
//

import Foundation

class AdvertDetailViewModel: ObservableObject {
    @Published var advert: Advert
    @Published var error: APIError?
    
    private var model: AdvertModel
    
    var toAuth: (() -> Void)?
    var navigateToUpdate: (() -> Void)?
    var onDelete: (() -> Void)?
    
    init(advert: Advert, model: AdvertModel) {
        self.advert = advert
        self.model = model
    }
    
    func updateAdvert() {
        navigateToUpdate?()
    }
    
    func deleteAdvert() {
        model.deleteAdvert(id: advert.id, onComplete: onDelete ?? {}, handleError: handleError)
    }
    
    private func handleError(error: APIError?) {
        if case .unauthorized = error {
            toAuth?()
        }
        self.error = error
    }
}
