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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    do {
                        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                case 400..<600:
                    print("Server Error Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
    }
}
