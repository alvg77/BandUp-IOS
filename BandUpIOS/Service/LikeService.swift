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
        
        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success:
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
