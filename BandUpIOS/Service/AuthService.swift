//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func login(loginRequest: LoginRequest) -> AnyPublisher<AuthResponse, APIError>
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError>
    func register(registerRequest: RegisterRequest) -> AnyPublisher<AuthResponse, APIError>
}

class AuthService {
    static let shared: AuthServiceProtocol = AuthService()
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/auth/")!
    
    private init() { }
}

extension AuthService: AuthServiceProtocol {
    func login(loginRequest: LoginRequest) -> AnyPublisher<AuthResponse, APIError> {
        let endpoint = AuthService.baseURL.appending(path: "login")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(loginRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: username, isUsername: true)
    }
    
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: email, isUsername: false)
    }
    
    internal func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError> {
        var endpoint = isUsername ? AuthService.baseURL.appendingPathComponent("available/username") : AuthService.baseURL.appendingPathComponent("available/email")
        
        endpoint.append(queryItems: [URLQueryItem(name: isUsername ? "username" : "email", value: credential)])
        
        return URLSession.shared.dataTaskPublisher(for: endpoint)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponseError
                }
                
                switch httpResponse.statusCode {
                case 200:
                    return CredentialAvailability.available
                case 409:
                    return CredentialAvailability.taken
                case 400..<600:
                    throw APIErrorMessage.getServerError(data: output.data)
                default:
                    throw APIError.unknownError
                }
            }
            .mapError { error -> APIError in
                if let urlError = error as? URLError {
                    return urlError.toAPIError()
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func register(registerRequest: RegisterRequest) -> AnyPublisher<AuthResponse, APIError> {
        let endpoint = AuthService.baseURL.appendingPathComponent("register")
        var request: URLRequest
        
        request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(registerRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}
