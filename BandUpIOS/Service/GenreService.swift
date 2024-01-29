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
        
        RequestHandler.makeRequest(request: URLRequest(url: endpoint)) { requestCompletion in
            switch requestCompletion {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.invalidResponseError))
                    return
                }
                do {
                    let response = try JSONDecoder().decode([Genre].self, from: data)
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
