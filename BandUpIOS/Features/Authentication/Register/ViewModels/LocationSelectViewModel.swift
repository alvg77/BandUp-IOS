//
//  RegisterLocationSelectViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine
import CoreLocation

class LocationSelectViewModel: ObservableObject, RegisterStepViewModel {
    @Published var country = ""
    @Published var city = ""
    @Published var zipcode = ""
    
    @Published var validateStep = false
    
    lazy var geocoder = CLGeocoder()
    
    var validateLocationData: AnyCancellable {
        Publishers.CombineLatest3($country.eraseToAnyPublisher(), $city.eraseToAnyPublisher(), $zipcode.eraseToAnyPublisher())
            .debounce(for: 0.4, scheduler: DispatchQueue.main)
            .sink { (country, city, zipcode) in
                if !country.isEmpty && !city.isEmpty && !zipcode.isEmpty {
                    
                }
            }
    }
    
    func validateLocation() {
        
    }
}
