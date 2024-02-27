//
//  RegisterLocationSelectViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine
import CoreLocation

class LocationSelectViewModel: LocationService, RegisterStepViewModel {
    var register: () -> Void
            
    var validateStep: Bool {
        getLocation() != nil
    }
    
    init(register: @escaping () -> Void) {
        self.register = register
    }
}
