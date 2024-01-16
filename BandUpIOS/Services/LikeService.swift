//
//  LikeService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 16.01.24.
//

import Foundation

protocol LikeServiceProtocol {
    func like(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void)
    func unlike(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void)
}

class LikeService {
    static let shared: LikeServiceProtocol = LikeService()
    private static let baseURL = URL(string: "http://localhost:9090/api/v1/likes")!

    private init() { }
}

extension LikeService: LikeServiceProtocol {
    func like(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = LikeService.baseURL.appending(queryItems: [URLQueryItem(name: "postId", value: "\(postId)")])
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error.toAPIError()))
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    completion(.success(Void()))
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
    
    func unlike(postId: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let endpoint = LikeService.baseURL.appending(queryItems: [URLQueryItem(name: "postId", value: "\(postId)")])
        
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
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponseError))
                return
            }

            let statusCode = httpResponse.statusCode
            if let data = data {
                switch statusCode {
                case 200..<300:
                    completion(.success(Void()))
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
}
