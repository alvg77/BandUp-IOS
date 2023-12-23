//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation
import Combine

struct RegisterService {
    private let baseURL = URL(string: "http://localhost:9090/api/v1/auth/available/")!
        
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: username, isUsername: true)
    }
    
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: email, isUsername: false)
    }
    
    private func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError> {
        let endpoint = isUsername ? baseURL.appendingPathComponent("username") : baseURL.appendingPathComponent("email")
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: isUsername ? "username" : "email", value: credential)]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidRequestError("Cannot build URL for the requested response.")).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return .available
                case 409:
                    return .taken
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.transportError("Cannot connect to the server. Please check your internet connection.")
                }
            }
            .eraseToAnyPublisher()
    }
    
    func register(registerRequest: RegisterRequest, completion: @escaping (Result<RegisterResponse, APIError>) -> Void) {
        print("register")
        
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/register")

        guard let url = components?.url else {
            completion(.failure(.invalidRequestError("Cannot build url for the requested resource.")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(APIError.invalidRequestError("Cannot build url for the requested response.")))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            let decoder = JSONDecoder()
            
            switch httpResponse.statusCode {
            case 200..<300:
                if let data = data {
                    do {
                        let response = try decoder.decode(RegisterResponse.self, from: data)
                        completion(.success(response))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    completion(.failure(.invalidResponse))
                }
            case 409:
                completion(.failure(.validationError("User with such username/email already exists.")))
            case 400..<499:
                if let data = data {
                    do {
                        let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                        completion(.failure(.validationError(apiError.detail)))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                } else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                }
            default:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        task.resume()
    }
}
