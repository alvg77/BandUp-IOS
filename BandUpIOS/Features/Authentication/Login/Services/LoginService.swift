//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation

struct LoginService {
    var payload: LoginRequest
    
    func login(completion: @escaping (Result<String, APIError>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/login")

        guard let url = components?.url else {
            completion(.failure(.invalidRequestError("Cannot construct url for the requested resource.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
                
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(.transportError("Cannot connect to the server. Please check your internet connection.")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            let decoder = JSONDecoder()
            if let data = data {
                switch httpResponse.statusCode {
                case 200..<300:
                    do {
                        let response = try decoder.decode(LoginResponse.self, from: data)
                        completion(.success(response.token))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                case 403:
                    completion(.failure(APIError.validationError("Invalid email or password.")))
                default:
                    do {
                        let apiError = try decoder.decode(APIErrorMessage.self, from: data)
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode, reason: apiError.reason)))
                    } catch let error {
                        completion(.failure(.decodingError(error)))
                    }
                }
            }
        }
        task.resume()
    }
}
