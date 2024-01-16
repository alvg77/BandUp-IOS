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
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                switch error.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    completion(.failure(.noInternetError))
                    return
                case .cannotConnectToHost:
                    completion(.failure(.cannotConnectToHost))
                    return
                case .timedOut:
                    completion(.failure(.timedOut))
                    return
                default:
                    completion(.failure(.unknownError))
                    return
                }
                
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
                        let response = try JSONDecoder().decode([PostFlair].self, from: data)
                        completion(.success(response))
                    } catch {
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
}
