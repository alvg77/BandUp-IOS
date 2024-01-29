//
//  PostService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation

protocol PostServiceProtocol {
    func create(postCreateRequest: CreateUpdatePost, completion: @escaping (Result<Post, APIError>) -> Void)
    func getById(postId: Int, completion: @escaping (Result<Post, APIError>) -> Void)
    func getAll(pageNo: Int, pageSize: Int, queryString: String?, flair: PostFlair?, completion: @escaping (Result<[Post], APIError>) -> Void)
    func update(postId: Int, postUpdateRequest: CreateUpdatePost, completion: @escaping (Result<Post, APIError>) -> Void)
    func delete(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void)
}

class PostService {
    static let shared: PostServiceProtocol = PostService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/community-posts")!
    private let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
}

extension PostService: PostServiceProtocol {
    func create(postCreateRequest: CreateUpdatePost, completion: @escaping (Result<Post, APIError>) -> Void) {
        var request = URLRequest(url: PostService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(postCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Post.self, from: data)
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
    
    func getById(postId: Int, completion: @escaping (Result<Post, APIError>) -> Void) {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Post.self, from: data)
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
    
    func getAll(pageNo: Int, pageSize: Int, queryString: String?, flair: PostFlair?, completion: @escaping (Result<[Post], APIError>) -> Void) {
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
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode([Post].self, from: data)
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
    
    func update(postId: Int, postUpdateRequest: CreateUpdatePost, completion: @escaping (Result<Post, APIError>) -> Void) {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(postUpdateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")

        RequestHandler.makeRequest(request: request) { [weak self] requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try self?.decoder.decode(Post.self, from: data)
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

    func delete(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = PostService.baseURL.appending(path: "/\(postId)")
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "DELETE"
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")

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
