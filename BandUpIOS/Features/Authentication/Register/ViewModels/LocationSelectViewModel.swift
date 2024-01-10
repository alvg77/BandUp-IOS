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
    var register: (() -> Void)?
    
    @Published var country = ""
    @Published var city = ""
    @Published var zipcode = ""
    
    var validateStep: Bool {
        true
    }
    
}
