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
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
        
    var validateStep: Bool {
        !selected.isEmpty
    }
    
    init() {
        getGenres()
    }
    
    func getGenres() {
        GenreFetchService.shared.getGenres { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let genres):
                    self?.genres = genres
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
