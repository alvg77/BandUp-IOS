//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation
import Combine
import Alamofire

protocol RegisterServiceProtocol {
    func checkUsernameAvailability(username: String, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void)
    func checkEmailAvailability(email: String, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void)
    func checkAvailability(for credential: String, isUsername: Bool, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void)
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void)
}

class RegisterService {
    static let shared: RegisterServiceProtocol = RegisterService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/auth/")!

    private init() { }
}

extension RegisterService: RegisterServiceProtocol {
    
    func checkUsernameAvailability(username: String, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void) {
        checkAvailability(for: username, isUsername: true, completion: completion)
    }
    
    func checkEmailAvailability(email: String, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void) {
        return checkAvailability(for: email, isUsername: false, completion: completion)
    }
    
    internal func checkAvailability(for credential: String, isUsername: Bool, completion: @escaping (Result<CredentialAvailability, APIError>) -> Void) {
        var endpoint = isUsername ? RegisterService.baseURL.appendingPathComponent("available/username") : RegisterService.baseURL.appendingPathComponent("available/email")
        
        endpoint.append(queryItems: [URLQueryItem(name: isUsername ? "username" : "email", value: credential)])
        
        AF.request(endpoint).validate().response { response in
            switch response.result {
            case .success(_):
                if let code = response.response?.statusCode, code == 200 {
                    completion(.success(.available))
                }
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
    
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
        let endpoint = RegisterService.baseURL.appendingPathComponent("register")
        
        AF.request(endpoint, method: .post, parameters: registerRequest, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: RegisterResponse.self)  { response in
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
