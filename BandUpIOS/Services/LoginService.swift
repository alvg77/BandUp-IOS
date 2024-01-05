//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation
import Combine

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
            case 200..<300:
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
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
