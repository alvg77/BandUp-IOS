//
//  RegisterProfileInfoViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine
import SwiftUI

class ProfileInfoViewModel: ObservableObject, RegisterStepViewModel {
    var next: (() -> Void)?
    
    @Published var artistType: ArtistType?
    @Published var bio = ""
    @Published var error: APIError?

    var artistTypes: [ArtistType] = []
    var cancellables = Set<AnyCancellable>()
        
    var validateStep: Bool {
        !bio.isEmpty && artistType != nil
    }
    
    init() {
        getArtistTypes()
    }
    
    func getArtistTypes() {
        ArtistTypeService.shared.getArtistTypes { [weak self] completion in
            switch completion {
            case .success(let artistTypes):
                self?.artistTypes = artistTypes
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
