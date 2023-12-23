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
    @Published var artistTypes: [ArtistType] = []
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
    let artistTypeService = ArtistTypeFetchService()
        
    var validateStep: Bool {
        !bio.isEmpty && artistType != nil
    }
    
    init() {
        getArtistTypes()
    }
    
    func getArtistTypes() {
        artistTypeService.getArtistTypes()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.error = nil
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] artistTypes in
                self?.artistTypes = artistTypes
            }
            .store(in: &cancellables)
    }
}
