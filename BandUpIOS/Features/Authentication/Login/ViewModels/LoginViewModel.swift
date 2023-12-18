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
    @Published var errorMessage = ""
    @Published var errorOccured = false
    @Published var error: APIError? = nil
    
    var toRegisterTapped: (() -> Void)?
    
    var veriftInput: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    init(toRegister: (() -> Void)?) {
        self.toRegisterTapped = toRegister
    }
    
    func login() {
        let defaults = UserDefaults.standard
        
        LoginService(payload: LoginRequest(email: email, password: password))
            .login { [weak self] completion in
                DispatchQueue.main.async {
                    switch completion {
                    case .success(let token):
                        defaults.setValue(token, forKey: "jwt")
                        // Route to main
                    case .failure(let error):
                        withAnimation {
                            self?.errorMessage = error.errorDescription
                            self?.errorOccured = true
                            self?.error = error
                        }
                    }
                }
            }
    }
}

