//
//  PostService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 8.01.24.
//

import Foundation

protocol PostServiceProtocol {
    func create(postCreateRequest: ModifyPost, completion: @escaping (Result<Post, APIError>) -> Void)
    func getById(postId: Int, completion: @escaping (Result<Post, APIError>) -> Void)
    func getAll(pageNo: Int, pageSize: Int, filter: PostFilter, completion: @escaping (Result<[ShortenedPost], APIError>) -> Void)
    func update(postId: Int, postUpdateRequest: ModifyPost, completion: @escaping (Result<Post, APIError>) -> Void)
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
    func create(postCreateRequest: ModifyPost, completion: @escaping (Result<Post, APIError>) -> Void) {
        var request = URLRequest(url: PostService.baseURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(postCreateRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    do {
                        let response = try self?.decoder.decode(Post.self, from: data)
                        completion(.success(response!))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                case 401:
                    completion(.failure(.unauthorized))
                case 400..<600:
                    print("Error Status Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
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
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            
            if let data = data {
                switch statusCode {
                case 200..<300:
                do {
                    let response = try self?.decoder.decode(Post.self, from: data)
                    completion(.success(response!))
                } catch {
                    completion(.failure(.decodingError))
                }
                case 401:
                    completion(.failure(.unauthorized))
                case 400..<600:
                    print("Error Status Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
    }
    
    func getAll(pageNo: Int, pageSize: Int, filter: PostFilter, completion: @escaping (Result<[ShortenedPost], APIError>) -> Void) {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "pageNo", value: "\(pageNo)"))
        queryItems.append(URLQueryItem(name: "pageSize", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "search", value: filter.search))
        queryItems.append(URLQueryItem(name: "flairId", value: filter.flairId != nil ? "\(filter.flairId!)" : nil))
        
        let endpoint = PostService.baseURL.appending(queryItems: queryItems)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode

            if let data = data {
                switch statusCode {
                case 200..<300:
                    do {
                        let response = try self?.decoder.decode([ShortenedPost].self, from: data)
                        completion(.success(response!))
                    } catch let error {
                        print(error.localizedDescription)
                        completion(.failure(.decodingError))
                    }
                case 401:
                    completion(.failure(.unauthorized))
                case 400..<600:
                    print("Server Error Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
    }
    
    func update(postId: Int, postUpdateRequest: ModifyPost, completion: @escaping (Result<Post, APIError>) -> Void) {
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

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    do {
                        let response = try self?.decoder.decode(Post.self, from: data)
                        completion(.success(response!))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                case 401:
                    completion(.failure(.unauthorized))
                case 400..<600:
                    print("Error Status Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.invalidResponseError))
            }
        }.resume()
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode

            switch statusCode {
            case 200..<300:
                completion(.success(Void()))
            case 401:
                completion(.failure(.unauthorized))
            case 400..<600:
                if let data = data {
                    print("Error Status Code: \(statusCode)")
                    completion(.failure(APIErrorMessage.getServerError(data: data)))
                } else {
                    completion(.failure(.invalidResponseError))
                }
            default:
                completion(.failure(.unknownError))
            }
        }.resume()
    }
}
