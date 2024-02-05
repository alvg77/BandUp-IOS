//
//  CommentService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 29.01.24.
//

import Foundation

protocol CommentServiceProtocol {
    func create(commentCreateRequest: CreateUpdateComment, completion: @escaping (Result<Comment, APIError>) -> Void)
    func getById(commentId: Int, completion: @escaping (Result<Comment, APIError>) -> Void)
    func getAll(postId: Int, pageNo: Int, pageSize: Int, completion: @escaping (Result<[Comment], APIError>) -> Void)
    func update(commentId: Int, commentUpdateRequest: CreateUpdateComment, completion: @escaping (Result<Comment, APIError>) -> Void)
    func delete(commentId: Int, completion: @escaping (Result<Void, APIError>) -> Void)
}

class CommentService {
    static let shared: CommentServiceProtocol = CommentService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/comments")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension CommentService: CommentServiceProtocol {
    func create(commentCreateRequest: CreateUpdateComment, completion: @escaping (Result<Comment, APIError>) -> Void) {
        var request = URLRequest(url: CommentService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(commentCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Comment.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getById(commentId: Int, completion: @escaping (Result<Comment, APIError>) -> Void) {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Comment.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAll(postId: Int, pageNo: Int, pageSize: Int, completion: @escaping (Result<[Comment], APIError>) -> Void) {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "postId", value: "\(postId)"))
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        
        let endpoint = CommentService.baseURL.appending(queryItems: queryItems)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode([Comment].self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func update(commentId: Int, commentUpdateRequest: CreateUpdateComment, completion: @escaping (Result<Comment, APIError>) -> Void) {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(commentUpdateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Comment.self, from: data)
                    guard let response = response else {
                        completion(.failure(.unknownError))
                        return
                    }
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(commentId: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = CommentService.baseURL.appending(path: "/\(commentId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success:
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
