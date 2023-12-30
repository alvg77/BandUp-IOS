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
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError>
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void)
}

class RegisterService {
    static let shared: RegisterServiceProtocol = RegisterService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/auth/")!

    private init() { }
}

extension RegisterService: RegisterServiceProtocol {
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: username, isUsername: true)
    }
    
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: email, isUsername: false)
    }
    
    internal func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError> {
        let endpoint = isUsername ? RegisterService.baseURL.appendingPathComponent("available/username") : RegisterService.baseURL.appendingPathComponent("available/email")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: isUsername ? "username" : "email", value: credential)]
        
        guard let url = components.url else {
            return Fail(error: .invalidURLError).eraseToAnyPublisher()
        }
        
        return AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { response in
                if response.response?.statusCode == 200 {
                    return .available
                }
                
                if response.response?.statusCode == 409 {
                    return .taken
                }
                
                if let code = response.response?.statusCode {
                    throw APIError.serverError(statusCode: code)
                }
                
                if let error = response.error, error.isSessionTaskError {
                    throw APIError.noConnectionError
                }
                
                throw APIError.unknownError
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
        let endpoint = RegisterService.baseURL.appendingPathComponent("register")
        let components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)
        
        guard let url = components?.url else {
            completion(.failure(.invalidURLError))
            return
        }
        
        AF.request(url, method: .post, parameters: registerRequest, encoder: JSONParameterEncoder.default)
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
                        completion(.failure(.noConnectionError))
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
