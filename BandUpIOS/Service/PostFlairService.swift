//
//  PostFlair.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 9.01.24.
//

import Foundation

protocol PostFlairServiceProtocol {
    func getPostFlairs(completion: @escaping (Result<[PostFlair], APIError>) -> Void)
}

class PostFlairService {
    static let shared: PostFlairServiceProtocol = PostFlairService()
    private init() { }
}

extension PostFlairService: PostFlairServiceProtocol {
    func getPostFlairs(completion: @escaping (Result<[PostFlair], APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/post-flairs")
        
        guard let endpoint = endpoint else {
            completion(.failure(.invalidURLError))
            return
        }
        
        var request = URLRequest(url: endpoint)
        
        guard let token = JWTService.shared.getToken() else {
            completion(.failure(.unauthorized))
            return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        RequestHandler.makeRequest(request: request) { requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try JSONDecoder().decode([PostFlair].self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
