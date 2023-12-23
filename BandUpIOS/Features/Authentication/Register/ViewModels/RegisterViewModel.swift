//
//  RegisterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 14.12.23.
//

import Foundation
import Combine

enum RegisterStep: String, CaseIterable {
    case credentials = "Credentials"
    case profileInfo = "Profile Info"
    case genres = "Genre Select"
    case location = "Location Select"
}

protocol RegisterStepViewModel {
    var validateStep: Bool { get }
}

class RegisterViewModel: ObservableObject {
    var registerCompleted: (() -> Void)?
    
    @Published var registerError: APIError?
    @Published var registerErrorOccured = false
    
    @Published var step = RegisterStep.credentials
    @Published var steps: [RegisterStep] = [.credentials]

    @Published var credentials = CredentialsViewModel()
    @Published var profileInfo = ProfileInfoViewModel()
    @Published var genreSelect = GenreSelectViewModel()
    @Published var locationSelect = LocationSelectViewModel()
    
    private var registerService = RegisterService()

    init() {
        credentials.next = goToNext
        profileInfo.next = goToNext
        genreSelect.next = goToNext
        locationSelect.register = register
    }

    func goToPrev() {
        step = step.previous()
        if steps.last != .credentials {
            steps.removeLast()
        }
    }
    
    func goToNext() {
        step = step.next()
        if steps.last != step {
            steps.append(step)
        }
    }
    
    func register() {
        let registerRequest = RegisterRequest(
            username: self.credentials.username,
            email: self.credentials.email,
            password: self.credentials.password,
            artistType: self.profileInfo.artistType!,
            genres: self.genreSelect.genres, 
            bio: self.profileInfo.bio
        )
        
        let defaults = UserDefaults.standard
        
        registerService.register(registerRequest: registerRequest) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let response):
                    self?.registerCompleted?()
                    defaults.setValue(response.token, forKey: "jwt")
                case .failure(let error):
                    self?.registerError = error
                    self?.registerErrorOccured = true
                }
            }
        }
    }
}
