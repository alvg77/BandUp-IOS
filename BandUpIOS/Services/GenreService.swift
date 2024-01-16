//
//  GenreFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation

protocol GenreServiceProtocol {
    func getGenres(completion: @escaping (Result<[Genre], APIError>) -> Void)
}

class GenreService {
    static let shared: GenreServiceProtocol = GenreService()
    private init() { }
}

extension GenreService: GenreServiceProtocol {
    func getGenres(completion: @escaping (Result<[Genre], APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/genres")
        
        guard let endpoint = endpoint else {
            completion(.failure(.invalidURLError))
            return
        }
        
        URLSession.shared.dataTask(with: endpoint) { data, response, error in
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
                    do {
                        let response = try JSONDecoder().decode([Genre].self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decodingError))
                    }
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
