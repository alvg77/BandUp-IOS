//
//  GenreFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation
import Combine

protocol GenreFetchServiceProtocol {
    func getGenres(completion: @escaping (Result<[Genre], APIError>) -> Void)
}

class GenreFetchService {
    static let shared: GenreFetchServiceProtocol = GenreFetchService()
    private init() { }
}

extension GenreFetchService: GenreFetchServiceProtocol {
    func getGenres(completion: @escaping (Result<[Genre], APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/genres")
        
        guard let endpoint = endpoint else {
            completion(.failure(.invalidURLError))
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
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
            
            switch statusCode {
            case 200..<300:
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode([Genre].self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.invalidResponseError))
                }
            case 400..<600:
                if let data = data {
                    do {
                        let reason = try JSONDecoder().decode(APIErrorMessage.self, from: data)
                        completion(.failure(.serverError(statusCode: statusCode, reason: reason.detail)))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.serverError(statusCode: statusCode)))
                }
            default:
                completion(.failure(.unknownError))
            }
        }.resume()
    }
}
