//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation
import Combine
import Alamofire

protocol LoginServiceProtocol {
    func login(loginRequest: LoginRequest, completion:  @escaping (Result<LoginResponse, APIError>) -> Void)
}

class LoginService {
    static let shared: LoginServiceProtocol = LoginService()
    
    private init() { }
}

extension LoginService: LoginServiceProtocol {
    func login(loginRequest: LoginRequest, completion:  @escaping (Result<LoginResponse, APIError>) -> Void) {
        let url = URL(string: "http://localhost:9090/api/v1/auth/login")
        
        guard let url = url else {
            completion(.failure(.invalidURLError))
            return
        }
        
        AF.request(url, method: .post, parameters: loginRequest, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    if let errorMessage = response.data.flatMap({ try? JSONDecoder().decode(APIErrorMessage.self, from: $0) }) {
                        completion(.failure(.serverError(statusCode: errorMessage.status, reason: errorMessage.detail)))
                        return
                    }
                    if let code = error.responseCode {
                        completion(.failure(.serverError(statusCode: code)))
                        return
                    }
                    if error.isSessionTaskError {
                        completion(.failure(.noInternetError))
                        return
                    }
                    if error.isResponseSerializationError {
                        completion(.failure(.decodingError))
                        return
                    }
                    completion(.failure(.unknownError))
                }
            }
    }
}
