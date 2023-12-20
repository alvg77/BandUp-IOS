//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation

struct RegisterService {
    func checkUsernameAvailabilty(username: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/available/username")
        
        guard var url = components?.url else {
            completion(.failure(APIError.invalidRequestError("Cannot build url for the requested response.")))
            return
        }
        url.append(queryItems: [URLQueryItem(name: "username", value: username)])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(.failure(APIError.transportError("Cannot connect to the server. Please check your internet connection.")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                completion(.success(true))
            case 409:
                completion(.success(false))
            default:
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        task.resume()
    }
    
    func checkEmailAvailability(email: String, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/available/email")
        
        guard var url = components?.url else {
            completion(.failure(APIError.invalidRequestError("Cannot build url for the requested response.")))
            return
        }
        url.append(queryItems: [URLQueryItem(name: "email", value: email)])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(.failure(APIError.transportError("Cannot connect to the server. Please check your internet connection.")))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                completion(.success(true))
            case 409:
                completion(.success(false))
            default:
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        task.resume()

    }
    
    func register() {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/register")

    
    }
}
