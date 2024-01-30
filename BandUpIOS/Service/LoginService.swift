//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation

protocol LoginServiceProtocol {
    func login(loginRequest: LoginRequest, completion:  @escaping (Result<LoginResponse, APIError>) -> Void)
}

class LoginService {
    static let shared: LoginServiceProtocol = LoginService()
    
    private init() { }
}

extension LoginService: LoginServiceProtocol {
    func login(loginRequest: LoginRequest, completion:  @escaping (Result<LoginResponse, APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/auth/login")
        
        guard let endpoint = endpoint else {
            completion(.failure(.invalidURLError))
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(loginRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
