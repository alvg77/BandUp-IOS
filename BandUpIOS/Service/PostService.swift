//
//  PostService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation
import Combine

protocol PostServiceProtocol {
    func create(postCreateRequest: CreateEditPost) -> AnyPublisher<Post, APIError>
    func getById(postId: Int) -> AnyPublisher<Post, APIError>
    func getAll(pageNo: Int, pageSize: Int, queryString: String?, flair: PostFlair?) -> AnyPublisher<[Post], APIError>
    func edit(postId: Int, postEditRequest: CreateEditPost) -> AnyPublisher<Post, APIError>
    func delete(postId: Int) -> AnyPublisher<Void, APIError>
}

class PostService {
    static let shared: PostServiceProtocol = PostService()
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/community-posts")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension PostService: PostServiceProtocol {
    func create(postCreateRequest: CreateEditPost) -> AnyPublisher<Post, APIError> {
        var request = URLRequest(url: PostService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(postCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Post.self, decoder: decoder)
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
    
    func getById(postId: Int) -> AnyPublisher<Post, APIError> {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: Post.self, decoder: decoder)
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
    
    func getAll(pageNo: Int, pageSize: Int, queryString: String?, flair: PostFlair?) -> AnyPublisher<[Post], APIError> {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "search", value: queryString))
        queryItems.append(URLQueryItem(name: "flairId", value: flair != nil ? "\(flair!.id)" : nil))
        
        let endpoint = PostService.baseURL.appending(queryItems: queryItems)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .decode(type: [Post].self, decoder: decoder)
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
    
    func edit(postId: Int, postEditRequest: CreateEditPost) -> AnyPublisher<Post, APIError> {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(postEditRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return RequestHandler.makeRequest(request: request)
            .decode(type: Post.self, decoder: decoder)
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

    func delete(postId: Int) -> AnyPublisher<Void, APIError> {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")

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
