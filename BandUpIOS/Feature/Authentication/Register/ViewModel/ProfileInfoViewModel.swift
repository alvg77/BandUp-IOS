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

    @Published var artistTypes: [ArtistType] = []
    @Published var artistType: ArtistType?
    @Published var bio = ""
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
        
    var validateStep: Bool {
        !bio.isEmpty && artistType != nil
    }
    
    init() { }
    
    func getArtistTypes() {
        loading = .loading
        ArtistTypeService.shared.getArtistTypes()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                case .failure(let error):
                    self?.loading = .notLoading
                    self?.error = error
                }
            } receiveValue: { [weak self] in
                self?.artistTypes = $0
                self?.error = nil
            }
            .store(in: &cancellables)
    }
}
