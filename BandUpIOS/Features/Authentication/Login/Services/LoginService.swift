//
//  LoginAction.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 11.12.23.
//

import Foundation
import Combine

struct LoginService {
    let components = URLComponents(string: "http://localhost:9090/api/v1/auth/login")
    
    func login(payload: LoginRequest) -> AnyPublisher<LoginResponse, APIError> {
        
        guard let url = components?.url else {
            return Fail(error: APIError.invalidRequestError("Cannot build url for requested resource")).eraseToAnyPublisher()
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

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if let error = httpResponse.statusCode.apiError {
                    throw error
                }

                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(LoginResponse.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
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
}
