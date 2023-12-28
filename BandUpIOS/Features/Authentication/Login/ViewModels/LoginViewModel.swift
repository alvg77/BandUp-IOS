//
//  LoginViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import Combine
import SwiftUI
import KeychainAccess
 
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var error: APIError?
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    var cancellables = Set<AnyCancellable>()
    
    var toRegisterTapped: (() -> Void)?
    
    var veriftInput: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    init(toRegister: (() -> Void)?) {
        self.toRegisterTapped = toRegister
    }
    
    func login() {
        
        LoginService.shared.login(loginRequest: LoginRequest(email: email, password: password))
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    withAnimation {
                        self?.error = error
                    }
                case .finished:
                    // route to default screen
                    print("finished")
                }
            } receiveValue: { [weak self] response in
                self?.keychain["jwt"] = response.token
            }
            .store(in: &cancellables)

    }
}

