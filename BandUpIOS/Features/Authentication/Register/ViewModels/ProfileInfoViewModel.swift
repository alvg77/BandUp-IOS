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
    @Published var artistType: ArtistType?
    @Published var bio = ""
    @Published var artistTypes: [ArtistType] = []
    @Published var errorMessage = ""
        
    var validateStep: Bool {
        !bio.isEmpty && artistType != nil
    }
    
    func getArtistTypes() {
        ArtistTypeFetchService()
            .getArtistTypes { [weak self] completion in
                DispatchQueue.main.async {
                    switch completion {
                    case .success(let artistTypes):
                        self?.artistTypes = artistTypes
                    case .failure(let error):
                        withAnimation {
                            self?.errorMessage = error.errorDescription
                        }
                    }
                }
            }
    }
}
