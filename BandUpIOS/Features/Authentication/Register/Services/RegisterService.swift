//
//  RegisterService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 15.12.23.
//

import Foundation
import Combine
import Alamofire

protocol RegisterServiceProtocol {
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError>
    func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError>
    func register(registerRequest: RegisterRequest) -> AnyPublisher<RegisterResponse, APIError>
}

class RegisterService {
    static let shared: RegisterServiceProtocol = RegisterService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/auth/")!

    private init() { }
}

extension RegisterService: RegisterServiceProtocol {
    func checkUsernameAvailability(username: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: username, isUsername: true)
    }
    
    func checkEmailAvailability(email: String) -> AnyPublisher<CredentialAvailability, APIError> {
        return checkAvailability(for: email, isUsername: false)
    }
    
    internal func checkAvailability(for credential: String, isUsername: Bool) -> AnyPublisher<CredentialAvailability, APIError> {
        let endpoint = isUsername ? RegisterService.baseURL.appendingPathComponent("available/username") : RegisterService.baseURL.appendingPathComponent("available/email")
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
                    return APIError.transportError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func register(registerRequest: RegisterRequest) -> AnyPublisher<RegisterResponse, APIError> {
        let endpoint = RegisterService.baseURL.appendingPathComponent("register")
        let components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)

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
                
                if let error = httpResponse.statusCode.apiError(data: data) {
                    throw error
                }
                
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(RegisterResponse.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
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
