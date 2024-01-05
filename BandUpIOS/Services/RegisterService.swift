//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation
import Combine

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
        
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    completion(.failure(.noInternetError))
                    return
                case .cannotConnectToHost:
                    completion(.failure(.cannotConnectToHost))
                    return
                case .timedOut:
                    completion(.failure(.timedOut))
                    return
                default:
                    completion(.failure(.unknownError))
                    return
                }
                
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                completion(.success(.available))
            default:
                if let data = data {
                    do {
                        let reason = try JSONDecoder().decode(APIErrorMessage.self, from: data)
                        completion(.failure(.serverError(statusCode: statusCode, reason: reason.detail)))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.serverError(statusCode: statusCode)))
                }
            }
        }.resume()
    }
    
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
        let endpoint = RegisterService.baseURL.appendingPathComponent("register")
        var request: URLRequest
        
        request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(registerRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    completion(.failure(.noInternetError))
                    return
                case .cannotConnectToHost:
                    completion(.failure(.cannotConnectToHost))
                    return
                case .timedOut:
                    completion(.failure(.timedOut))
                    return
                default:
                    completion(.failure(.unknownError))
                    return
                }
                
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200..<300:
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.invalidResponseError))
                }
            case 400..<600:
                if let data = data {
                    do {
                        let reason = try JSONDecoder().decode(APIErrorMessage.self, from: data)
                        completion(.failure(.serverError(statusCode: statusCode, reason: reason.detail)))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.serverError(statusCode: statusCode)))
                }
            default:
                completion(.failure(.unknownError))
            }
        }.resume()
    }
}
