//
//  LikeService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 16.01.24.
//

import Foundation
import Combine

protocol LikeServiceProtocol {
    func like(postId: Int) -> AnyPublisher<Void, APIError>
    func unlike(postId: Int) -> AnyPublisher<Void, APIError>
}

class LikeService {
    static let shared: LikeServiceProtocol = LikeService()
    private static let baseURL = URL(string: "\(Secrets.baseApiURL)/likes")!

    private init() { }
}

extension LikeService: LikeServiceProtocol {
    func like(postId: Int) -> AnyPublisher<Void, APIError> {
        let endpoint = LikeService.baseURL.appending(queryItems: [URLQueryItem(name: "postId", value: "\(postId)")])
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        guard let token = JWTService.shared.getToken() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return RequestHandler.makeRequest(request: request)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
    
    func unlike(postId: Int) -> AnyPublisher<Void, APIError> {
        let endpoint = LikeService.baseURL.appending(queryItems: [URLQueryItem(name: "postId", value: "\(postId)")])
        
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
