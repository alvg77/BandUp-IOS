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
    @Published var step = RegisterStep.credentials
    @Published var steps: [RegisterStep] = [.credentials]

    @Published var credentials: CredentialsViewModel
    @Published var profileInfo: ProfileInfoViewModel
    @Published var genreSelect: GenreSelectViewModel
    @Published var locationSelect: LocationSelectViewModel
    
    private var registerService = RegisterService()

    init() {
        credentials = CredentialsViewModel(registerService: RegisterService())
        profileInfo = ProfileInfoViewModel()
        genreSelect = GenreSelectViewModel()
        locationSelect = LocationSelectViewModel()
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
        
    }
}
