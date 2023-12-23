//
//  LoginViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import Combine
import SwiftUI
 
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var error: APIError?
    
    var cancellables = Set<AnyCancellable>()
    
    var toRegisterTapped: (() -> Void)?
    
    var veriftInput: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    init(toRegister: (() -> Void)?) {
        self.toRegisterTapped = toRegister
    }
    
    func login() {
        let defaults = UserDefaults.standard
        
        LoginService().login(payload: LoginRequest(email: email, password: password))
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
            } receiveValue: { data in
                defaults.setValue(data.token, forKey: "jwt")
            }
            .store(in: &cancellables)

    }
}

