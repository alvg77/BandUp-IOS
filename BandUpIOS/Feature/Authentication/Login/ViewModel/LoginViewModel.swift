//
//  LoginViewModel.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.12.23.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var error: APIError?
    
    var navigateToRegister: (() -> Void)?
    var onComplete: (() -> Void)?
    
    var verifyInput: Bool {
        !email.isEmpty && !password.isEmpty
    }
        
    func login() {
        AuthService.shared.login(loginRequest: LoginRequest(email: email, password: password)) { [weak self] completion in
            DispatchQueue.main.async {
                switch completion {
                case .success(let response):
                    JWTService.shared.saveToken(token: response.token)
                    self?.onComplete?()
                case .failure(let error):
                    withAnimation {
                        self?.error = error
                    }
                }
            }
        }
    }
}

