//
//  ArtistTypeFetchService.swift
//  BandUpIOS
//
//  Created by Aleko Georgiev on 13.12.23.
//

import Foundation

protocol ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void)
}

class ArtistTypeService {
    static let shared: ArtistTypeServiceProtocol = ArtistTypeService()
    private init() { }
}

extension ArtistTypeService: ArtistTypeServiceProtocol {
    func getArtistTypes(completion: @escaping (Result<[ArtistType], APIError>) -> Void) {
        let endpoint = URL(string: "http://localhost:9090/api/v1/artist-types")
        
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
                    let response = try JSONDecoder().decode([ArtistType].self, from: data)
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
