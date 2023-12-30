//
//  RegisterViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 14.12.23.
//

import Foundation
import Combine
import KeychainAccess

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
    let authenticate: (() -> Void)?

    @Published var registerError: APIError?
    @Published var registerErrorOccured = false
    
    @Published var step = RegisterStep.credentials
    @Published var steps: [RegisterStep] = [.credentials]

    var credentials = CredentialsViewModel()
    var profileInfo = ProfileInfoViewModel()
    var genreSelect = GenreSelectViewModel()
    var locationSelect = LocationSelectViewModel()
    
    private var keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private var cancellables = Set<AnyCancellable>()
    
    init(authenticate: (() -> Void)?) {
        self.authenticate = authenticate

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
            artistTypeId: self.profileInfo.artistType!.id,
            genreIds: self.genreSelect.genres.map { $0.id },
            bio: self.profileInfo.bio
        )
                
        RegisterService.shared.register(registerRequest: registerRequest) { [weak self] completion in
            switch completion {
            case .success(let response):
                JWTService.shared.saveToken(token: response.token)
                self?.authenticate?()
            case .failure(let error):
                self?.registerError = error
                self?.registerErrorOccured = true
            }
        }
    }
}
