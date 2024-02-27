//
//  UserService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.02.24.
//

import Foundation
import Combine

protocol ProfileServiceProtocol {
    func fetchCurrentUser() -> AnyPublisher<User, APIError>
    func fetchUserById(id: Int) -> AnyPublisher<User, APIError>
    func fetchUser(id: Int?) -> AnyPublisher<User, APIError>
    func editProfile(id: Int, profileEditRequest: EditUser) -> AnyPublisher<User, APIError>
    func deleteProfile(id: Int) -> AnyPublisher<Void, APIError>
}

class ProfileService {
    static let shared: ProfileServiceProtocol = ProfileService()
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/users")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension ProfileService: ProfileServiceProtocol {
    internal func fetchCurrentUser() -> AnyPublisher<User, APIError> {
        let endpoint = ProfileService.baseURL.appending(path: "me")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
        return RequestHandler.makeRequest(request: request)
            .decode(type: User.self, decoder: decoder)
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    internal func fetchUserById(id: Int) -> AnyPublisher<User, APIError> {
        let endpoint = ProfileService.baseURL.appending(path: "\(id)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: User.self, decoder: decoder)
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchUser(id: Int?) -> AnyPublisher<User, APIError> {
        if let id = id {
            return fetchUserById(id: id)
        } else {
            return fetchCurrentUser()
        }
    }
    
    func editProfile(id: Int, profileEditRequest: EditUser) -> AnyPublisher<User, APIError> {
        var request = URLRequest(url: ProfileService.baseURL)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(profileEditRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: User.self, decoder: decoder)
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingError
                case is APIError:
                    return error as! APIError
                default:
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteProfile(id: Int) -> AnyPublisher<Void, APIError> {
        var request = URLRequest(url: ProfileService.baseURL)
        request.httpMethod = "DELETE"
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
