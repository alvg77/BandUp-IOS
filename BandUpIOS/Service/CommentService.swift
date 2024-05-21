//
//  CommentService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation
import Combine

public protocol CommentServiceProtocol {
    func create(commentCreateRequest: CreateEditComment) -> AnyPublisher<Comment, APIError>
    func getById(commentId: Int) -> AnyPublisher<Comment, APIError>
    func getAll(postId: Int, pageNo: Int, pageSize: Int) -> AnyPublisher<[Comment], APIError>
    func edit(commentId: Int, commentEditRequest: CreateEditComment) -> AnyPublisher<Comment, APIError>
    func delete(commentId: Int) -> AnyPublisher<Void, APIError>
}

class CommentService {
    static let shared: CommentServiceProtocol = CommentService()
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/comments")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension CommentService: CommentServiceProtocol {
    func create(commentCreateRequest: CreateEditComment) -> AnyPublisher<Comment, APIError> {
        var request = URLRequest(url: CommentService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(commentCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Comment.self, decoder: decoder)
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
    
    func getById(commentId: Int) -> AnyPublisher<Comment, APIError> {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Comment.self, decoder: decoder)
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
    
    func getAll(postId: Int, pageNo: Int, pageSize: Int) -> AnyPublisher<[Comment], APIError> {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "postId", value: "\(postId)"))
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        
        let endpoint = CommentService.baseURL.appending(queryItems: queryItems)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: [Comment].self, decoder: decoder)
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
    
    func edit(commentId: Int, commentEditRequest: CreateEditComment) -> AnyPublisher<Comment, APIError> {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(commentEditRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return RequestHandler.makeRequest(request: request)
            .decode(type: Comment.self, decoder: decoder)
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

    func delete(commentId: Int) -> AnyPublisher<Void, APIError> {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
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
