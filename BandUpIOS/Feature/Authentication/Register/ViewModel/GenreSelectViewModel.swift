//
//  RegisterGenreSelectViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 10.12.23.
//

import Foundation
import Combine

class GenreSelectViewModel: ObservableObject, RegisterStepViewModel {
    var next: (() -> Void)?
    
    @Published var genres: [Genre] = []
    @Published var selected: [Genre] = []
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
        
    var validateStep: Bool {
        !selected.isEmpty
    }
    
    init() { }
    
    func getGenres() {
        loading = .loading
        GenreService.shared.getGenres()
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
                self?.genres = $0
                self?.error = nil
            }
            .store(in: &cancellables)
    }
}
