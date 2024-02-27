//
//  LoginViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import SwiftUI
import Combine

final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var loading: LoadingState = .notLoading
    @Published var error: APIError?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let navigateToRegister: () -> Void
    private let onComplete: () -> Void
    
    var verifyInput: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    init(
        navigateToRegister: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.navigateToRegister = navigateToRegister
        self.onComplete = onComplete
    }
    
    func register() {
        navigateToRegister()
    }
    
    func login() {
        loading = .loading
        let loginRequest = LoginRequest(email: email, password: password)
        AuthService.shared.login(loginRequest: loginRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.loading = .notLoading
                    self?.onComplete()
                case .failure(let error):
                    self?.loading = .notLoading
                    withAnimation {
                        self?.error = error
                    }
                }
            } receiveValue: {
                JWTService.shared.saveToken(token: $0.token)
            }
            .store(in: &cancellables)
    }
}

