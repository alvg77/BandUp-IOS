//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation


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
                completion(.failure(error.toAPIError()))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                completion(.success(.available))
            case 409:
                completion(.success(.taken))
            default:
                if let data = data {
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                } else {
                    completion(.failure(.invalidResponseError))
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

        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
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
