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
    
    func register(registerRequest: RegisterRequest) -> AnyPublisher<RegisterResponse, APIError> {
        let components = URLComponents(string: "http://localhost:9090/api/v1/auth/register")

        guard let url = components?.url else {
            return Fail(error: .invalidRequestError("Cannot build URL for the requested resource.")).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(registerRequest)
        } catch {
            return Fail(error: .invalidRequestError("Failed to encode registerRequest.")).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                let decoder = JSONDecoder()
                switch httpResponse.statusCode {
                case 200..<300:
                    if let response = try? decoder.decode(RegisterResponse.self, from: data) {
                        return response
                    } else {
                        throw APIError.decodingError(NSError(domain: "", code: 0, userInfo: nil))
                    }
                case 409:
                    throw APIError.validationError("User with such username/email already exists.")
                case 400..<500:
                    if let apiError = try? decoder.decode(APIErrorMessage.self, from: data) {
                        throw APIError.validationError(apiError.detail)
                    } else {
                        throw APIError.serverError(statusCode: httpResponse.statusCode)
                    }
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
}
