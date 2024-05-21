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
    case contacts = "Contacts"
    case profileInfo = "Profile Info"
    case genres = "Genre Select"
    case location = "Location Select"
}

protocol RegisterStepViewModel {
    var validateStep: Bool { get }
}

class RegisterViewModel: ObservableObject {
    @Published var registerError: APIError?
    @Published var loading: LoadingState = .notLoading
    @Published var step = RegisterStep.credentials
    @Published var steps: [RegisterStep] = [.credentials]
    
    lazy var credentials = { CredentialsViewModel(next: goToNext) }()
    lazy var contacts = { ContactsViewModel(next: goToNext) }()
    lazy var profileInfo = { ProfileInfoViewModel(next: goToNext) }()
    lazy var genreSelect = { GenreSelectViewModel(next: goToNext) }()
    lazy var locationSelect = { LocationSelectViewModel(register: register) }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
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
        loading = .loading
        let registerRequest = RegisterRequest(
            username: self.credentials.username,
            email: self.credentials.email,
            password: self.credentials.password,
            artistTypeId: self.profileInfo.artistType!.id,
            genreIds: self.genreSelect.selected.map { $0.id },
            bio: self.profileInfo.bio,
            location: self.locationSelect.getLocation()!,
            contacts: Contacts(
                phoneNumber: self.contacts.phoneNumber.isEmpty ? nil : self.contacts.phoneNumberCountryCode + " " + self.contacts.phoneNumber,
                contactEmail: self.contacts.contactEmail.isEmpty ? nil : self.contacts.contactEmail,
                website: self.contacts.website.isEmpty ? nil : self.contacts.website
            )
        )
        
        AuthService.shared.register(registerRequest: registerRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                    self?.onComplete()
                case .failure(let error):
                    self?.loading = .notLoading
                    self?.registerError = error
                }
            } receiveValue: { 
                JWTService.shared.saveToken(token: $0.token)
            }
            .store(in: &cancellables)
    }
}
